import json
import base64
import pytest
from unittest.mock import patch, MagicMock
import sys
import os

# Add the src directory to Python path
current_dir = os.path.dirname(os.path.abspath(__file__))
src_dir = os.path.join(current_dir, "..", "src")
sys.path.insert(0, os.path.abspath(src_dir))
print(f"Looking for transform_lambda.py in: {os.path.abspath(src_dir)}")
print(f"Files in src directory: {os.listdir(os.path.abspath(src_dir))}")

from transform_lambda import lambda_handler, process_metric, default_keys_to_remove


class TestLambdaHandler:

    def test_lambda_handler_single_metric_line(self):
        """Test processing a single metric line"""
        # Sample metric data as newline-delimited JSON
        metric_data = {
            "timestamp": 1640995200000,
            "metric_stream_name": "test-stream",
            "account_id": "123456789012",
            "region": "us-east-1",
            "namespace": "AWS/ES",
            "metric_name": "CPUUtilization",
            "dimensions": {
                "InstanceId": "i-1234567890abcdef0",
                "ClientId": "client123",
            },
            "value": 85.5,
            "unit": "Percent",
        }

        # Create newline-delimited JSON
        ndjson_data = json.dumps(metric_data) + "\n"
        encoded_data = base64.b64encode(ndjson_data.encode("utf-8")).decode("utf-8")

        event = {"records": [{"recordId": "test-record-1", "data": encoded_data}]}

        context = MagicMock()

        with patch("transform_lambda.logger"):
            result = lambda_handler(event, context)

        # Assertions
        assert "records" in result
        assert len(result["records"]) == 1
        assert result["records"][0]["recordId"] == "test-record-1"
        assert result["records"][0]["result"] == "Ok"

        # Decode and verify output
        output_data = base64.b64decode(result["records"][0]["data"]).decode("utf-8")
        output_metrics = [json.loads(line) for line in output_data.strip().split("\n")]

        assert len(output_metrics) == 1
        metric = output_metrics[0]

        # Verify keys were removed
        assert "metric_stream_name" not in metric
        assert "account_id" not in metric
        assert "region" not in metric

        # Verify ClientId was removed from dimensions
        assert "ClientId" not in metric["dimensions"]

        # Verify core data is preserved
        assert metric["namespace"] == "AWS/ES"
        assert metric["metric_name"] == "CPUUtilization"
        assert metric["value"] == 85.5
        assert "processed_at" in metric

    def test_lambda_handler_multiple_metric_lines(self):
        """Test processing multiple metric lines in one record"""
        metrics = [
            {
                "timestamp": 1640995200000,
                "metric_stream_name": "test-stream",
                "namespace": "AWS/ES",
                "metric_name": "CPUUtilization",
                "dimensions": {"InstanceId": "i-123"},
                "value": 85.5,
                "unit": "Percent",
            },
            {
                "timestamp": 1640995260000,
                "metric_stream_name": "test-stream",
                "namespace": "AWS/S3",
                "metric_name": "BucketSizeBytes",
                "dimensions": {"BucketName": "TestingCheatsEnabled"},
                "value": 50,
                "unit": "Bytes",
            },
        ]

        # Create newline-delimited JSON
        ndjson_data = "\n".join([json.dumps(metric) for metric in metrics]) + "\n"
        encoded_data = base64.b64encode(ndjson_data.encode("utf-8")).decode("utf-8")

        event = {"records": [{"recordId": "multi-metric-record", "data": encoded_data}]}

        context = MagicMock()

        with patch("transform_lambda.logger"):
            result = lambda_handler(event, context)

        assert len(result["records"]) == 1
        assert result["records"][0]["result"] == "Ok"

        # Decode and verify multiple metrics
        output_data = base64.b64decode(result["records"][0]["data"]).decode("utf-8")
        output_metrics = [json.loads(line) for line in output_data.strip().split("\n")]

        assert len(output_metrics) == 2
        assert output_metrics[0]["namespace"] == "AWS/ES"
        assert output_metrics[1]["namespace"] == "AWS/S3"

    def test_lambda_handler_multiple_records(self):
        """Test processing multiple records"""
        records = []
        for i in range(3):
            metric_data = {
                "timestamp": 1640995200000 + i,
                "namespace": f"AWS/Service{i}",
                "metric_name": f"TestMetric{i}",
                "dimensions": {"ResourceId": f"resource-{i}"},
                "value": 100 + i,
                "unit": "Count",
            }
            ndjson_data = json.dumps(metric_data) + "\n"
            encoded_data = base64.b64encode(ndjson_data.encode("utf-8")).decode("utf-8")

            records.append({"recordId": f"record-{i}", "data": encoded_data})

        event = {"records": records}
        context = MagicMock()

        with patch("transform_lambda.logger"):
            result = lambda_handler(event, context)

        assert len(result["records"]) == 3
        for i, record in enumerate(result["records"]):
            assert record["recordId"] == f"record-{i}"
            assert record["result"] == "Ok"

    def test_lambda_handler_empty_metrics_filtered(self):
        """Test that records with no valid metrics are filtered out"""
        # Invalid metric (missing required fields)
        invalid_metric = {
            "timestamp": 1640995200000,
            "namespace": "AWS/Test",
            # Missing metric_name and value
        }

        ndjson_data = json.dumps(invalid_metric) + "\n"
        encoded_data = base64.b64encode(ndjson_data.encode("utf-8")).decode("utf-8")

        event = {"records": [{"recordId": "invalid-record", "data": encoded_data}]}

        context = MagicMock()

        with patch("transform_lambda.logger"):
            result = lambda_handler(event, context)

        # Should return empty records list since no valid metrics
        assert len(result["records"]) == 0

    def test_lambda_handler_malformed_json(self):
        """Test handling of malformed JSON"""
        malformed_data = "{'invalid': json}"  # Not valid JSON
        encoded_data = base64.b64encode(malformed_data.encode("utf-8")).decode("utf-8")

        event = {"records": [{"recordId": "malformed-record", "data": encoded_data}]}

        context = MagicMock()

        with patch("transform_lambda.logger") as mock_logger:
            result = lambda_handler(event, context)

        # Should handle gracefully and return empty records
        assert len(result["records"]) == 0
        mock_logger.error.assert_called()

    def test_process_metric_valid(self):
        """Test process_metric function with valid data"""
        input_metric = {
            "timestamp": 1640995200000,
            "namespace": "AWS/S3",
            "metric_name": "Duration",
            "dimensions": {"FunctionName": "my-function"},
            "value": 150.5,
            "unit": "Milliseconds",
        }

        result = process_metric(input_metric)

        assert result is not None
        assert result["namespace"] == "AWS/S3"
        assert result["metric_name"] == "Duration"
        assert result["value"] == 150.5
        assert "processed_at" in result

    def test_process_metric_missing_required_fields(self):
        """Test process_metric with missing required fields"""
        # Missing metric_name
        invalid_metric = {
            "timestamp": 1640995200000,
            "namespace": "AWS/Test",
            "value": 100,
        }

        result = process_metric(invalid_metric)
        assert result is None

        # Missing value
        invalid_metric2 = {
            "timestamp": 1640995200000,
            "namespace": "AWS/Test",
            "metric_name": "TestMetric",
        }

        result2 = process_metric(invalid_metric2)
        assert result2 is None

    def test_key_removal_configuration(self):
        """Test that default keys are properly configured"""
        expected_keys = ["metric_stream_name", "account_id", "region"]
        assert default_keys_to_remove == expected_keys

    def test_clientid_dimension_removal(self):
        """Test that ClientId is removed from dimensions"""
        metric_data = {
            "timestamp": 1640995200000,
            "namespace": "AWS/Test",
            "metric_name": "TestMetric",
            "dimensions": {
                "InstanceId": "i-123",
                "ClientId": "should-be-removed",
                "OtherDim": "should-stay",
            },
            "value": 100,
        }

        ndjson_data = json.dumps(metric_data) + "\n"
        encoded_data = base64.b64encode(ndjson_data.encode("utf-8")).decode("utf-8")

        event = {"records": [{"recordId": "test-record", "data": encoded_data}]}

        context = MagicMock()

        with patch("transform_lambda.logger"):
            result = lambda_handler(event, context)

        output_data = base64.b64decode(result["records"][0]["data"]).decode("utf-8")
        output_metric = json.loads(output_data.strip())

        assert "ClientId" not in output_metric["dimensions"]
        assert "InstanceId" in output_metric["dimensions"]
        assert "OtherDim" in output_metric["dimensions"]
