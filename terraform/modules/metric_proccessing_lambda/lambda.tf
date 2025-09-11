resource "aws_lambda_function" "transform" {
  for_each = toset(var.environments)

  filename         = data.archive_file.lambda_zip[each.key].output_path
  function_name    = "${var.name_prefix}-${each.key}-transform"
  role             = aws_iam_role.lambda_role[each.key].arn
  handler          = "lambda_function_${each.key}.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip[each.key].output_base64sha256
  runtime          = "python3.13"
  architectures    = ["arm64"]

  timeout = 10

  environment {
    variables = {
      ENVIRONMENT = each.key
    }
  }

  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

resource "local_file" "lambda_source" {
  for_each = toset(var.environments)
  content  = <<EOF
import json
import base64
import boto3
import logging
import gzip
import io
import os

s3 = boto3.client("s3")
tagging_client = boto3.client("resourcegroupstaggingapi")

logger = logging.getLogger()
logger.setLevel(logging.INFO)
default_keys_to_remove = ["metric_stream_name","account_id","region"]
nested_keys_to_remove = []
EXPECTED_NAMESPACES = ["AWS/S3", "AWS/ES"]
environment = os.environ.get('ENVIRONMENT', 'unknown')

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
            pre_json_value = base64.b64decode(record['data'])
            logger.info(f"Processing")
            processed_metrics = []
            for line in pre_json_value.strip().splitlines():
                metric = json.loads(line)
                for key in default_keys_to_remove:
                    metric.pop(key,None)
                metric_results = process_metric(metric)
                if metric_results is not None:
                    metric_results["dimensions"].pop("ClientId", None)
                    processed_metrics.append(metric_results)

            if processed_metrics:
                # Create newline-delimited JSON (no compression)
                output_data = '\n'.join([json.dumps(metric) for metric in processed_metrics]) + '\n'

                # Just base64 encode for Firehose transport (no gzip)
                encoded_output = base64.b64encode(output_data.encode('utf-8')).decode('utf-8')

                output_record = {
                    'recordId': record['recordId'],
                    'result': 'Ok',
                    'data': encoded_output
                }
                output_records.append(output_record)

            logger.info(f"Processed record with {len(processed_metrics)} metrics")
    except Exception as e:
        logger.error(f"Error processing metrics: {str(e)}")
        raise
    return {'records': output_records}

def process_metric(metric):
    try:
        namespace = metric.get("namespace")
        if namespace not in EXPECTED_NAMESPACES:
            logger.error(
                f"Hello developer, you need to add the following metric to the lambda function: {str(namespace)}"
            )

        metrics_arn = get_resource_arn_from_metric(metric)
        tags = {}
        if metrics_arn:
            tags = get_resource_tags(metrics_arn)

        if tags:
            metric["Tags"] = tags
            return metric
        else:
            return None
    except Exception as e:
        logger.error("Could not process metric")
        print(e)
        return None

def get_resource_arn_from_metric(metric):
    try:
        namespace = metric.get("namespace")
        dimensions = metric.get("dimensions", {})
        if namespace == "AWS/S3":
            bucket_name = dimensions.get("BucketName")
            if bucket_name.startswith(s3_prefix):
                return f"arn:aws-us-gov:s3:::{bucket_name}"
        elif namespace == "AWS/ES":
            domain_name = dimensions.get("DomainName")
            client_id = dimensions.get("ClientId")
            if domain_name.startswith(domain_prefix) and client_id:
                region = boto3.Session().region_name
                return f"arn:aws-us-gov:es:{region}:{client_id}:domain/{domain_name}"
        return None
    except Exception:
        logger.error("Error with Arn")
        return None

def get_resource_tags(resource_arn):
    try:
        response = tagging_client.get_resources(ResourceARNList=[resource_arn])
        if response["ResourceTagMappingList"]:
            resource = response["ResourceTagMappingList"][0]
            tags = {}
            for tag in resource.get("Tags", []):
                tags[tag["Key"]] = tag["Value"]
            return tags
        return {}
    except Exception as e:
        logger.error(f"Error getting tags: {str(e)}")
        return None
EOF
  filename = "${path.module}/lambda_function_${each.key}.py"
}

data "archive_file" "lambda_zip" {
  for_each    = toset(var.environments)
  type        = "zip"
  source_file = local_file.lambda_source[each.key].filename
  output_path = "${path.module}/lambda_function_${each.key}.zip"
  depends_on  = [local_file.lambda_source]
}
