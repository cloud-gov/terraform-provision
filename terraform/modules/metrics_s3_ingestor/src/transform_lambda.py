import json
import base64
import boto3
import logging
import gzip
import io
import os

s3_client = boto3.client("s3")
es_client = boto3.client("opensearch")
region = boto3.Session().region_name

logger = logging.getLogger()
logger.setLevel(logging.INFO)
default_keys_to_remove = ["metric_stream_name", "account_id", "region"]
nested_keys_to_remove = []
EXPECTED_NAMESPACES = ["AWS/S3", "AWS/ES"]
environment = os.environ.get("ENVIRONMENT", "unknown")

# Prefix setup zone
s3_prefix = f"{environment}-cg-" if environment in ["development", "staging"] else "cg-"
domain_prefix = "cg-broker-"
if environment == "production":
    domain_prefix = domain_prefix + "prd-"
if environment == "staging":
    domain_prefix = domain_prefix + "stg-"
if environment == "development":
    domain_prefix = domain_prefix + "dev-"


def lambda_handler(event, context):
    output_records = []
    try:
        for record in event["records"]:
            pre_json_value = base64.b64decode(record["data"])
            logger.info(f"Processing")
            processed_metrics = []
            for line in pre_json_value.strip().splitlines():
                metric = json.loads(line)
                for key in default_keys_to_remove:
                    metric.pop(key, None)
                metric_results = process_metric(metric)
                if metric_results is not None:
                    metric_results["dimensions"].pop("ClientId", None)
                    processed_metrics.append(metric_results)

            if processed_metrics:
                # Create newline-delimited JSON (no compression)
                output_data = (
                    "\n".join([json.dumps(metric) for metric in processed_metrics])
                    + "\n"
                )

                # Just base64 encode for Firehose transport (no gzip)
                encoded_output = base64.b64encode(output_data.encode("utf-8")).decode(
                    "utf-8"
                )

                output_record = {
                    "recordId": record["recordId"],
                    "result": "Ok",
                    "data": encoded_output,
                }
                output_records.append(output_record)

            logger.info(f"Processed record with {len(processed_metrics)} metrics")
    except Exception as e:
        logger.error(f"Error processing metrics: {str(e)}")
    return {"records": output_records}


def process_metric(metric):
    try:
        namespace = metric.get("namespace")
        if namespace not in EXPECTED_NAMESPACES:
            logger.error(
                f"Hello developer, you need to add the following metric to the lambda function: {str(namespace)}"
            )
            return None

        tags = get_resource_tags_from_metric(metric)
        if tags and tags != []:
            metric["Tags"] = tags
            return metric
        else:
            return None
    except Exception as e:
        logger.error(f"Could not process metric: {e}")
        return None


def get_resource_tags_from_metric(metric):
    try:
        namespace = metric.get("namespace")
        dimensions = metric.get("dimensions", {})
        if namespace == "AWS/S3":
            bucket_name = dimensions.get("BucketName")
            if bucket_name.startswith(s3_prefix):
                result = get_tags_from_name(bucket_name, "S3")
                return None if result == {} else result
        elif namespace == "AWS/ES":
            domain_name = dimensions.get("DomainName")
            client_id = dimensions.get("ClientId")
            if domain_name.startswith(domain_prefix) and client_id:
                arn = f"arn:aws-us-gov:es:{region}:{client_id}:domain/{domain_name}"
                result = get_tags_from_arn(arn)
                return None if result == {} else result
        return None
    except Exception:
        logger.error("Error with Arn")
        return None


def get_tags_from_name(name, type):
    if type == "S3":
        try:
            response = s3_client.get_bucket_tagging(Bucket=name)
            return {tag["Key"]: tag["Value"] for tag in response.get("TagSet", [])}
        except s3_client.exceptions.NoSuchTagSet:
            return []


def get_tags_from_arn(arn):
    if ":domain/" in arn:
        try:
            response = es_client.list_tags(ARN=arn)
            return {tag["Key"]: tag["Value"] for tag in response.get("TagList", [])}
        except Exception as e:
            logger.error("Failed to tag domain" + e)
            return []
