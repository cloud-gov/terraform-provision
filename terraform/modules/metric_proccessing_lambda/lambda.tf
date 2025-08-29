resource "aws_lambda_function" "transform" {
  for_each = toset(var.environments)

  filename         = data.archive_file.lambda_zip[each.key].output_path
  function_name    = "${var.name_prefix}-${each.key}-transform"
  role             = aws_iam_role.lambda_role[each.key].arn
  handler          = "lambda_function.lambda_handler"
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

s3 = boto3.client("s3")
tagging_client = boto3.client("resourcegroupstaggingapi")

logger = logging.getLogger()
logger.setLevel(logging.INFO)
keys_to_remove = ["metric_stream_name","account_id","region"]
EXPECTED_NAMESPACES = ["AWS/S3", "AWS/ES"]
environment = os.environ.get('ENVIRONMENT'. 'unknown')

def lambda_handler(event, context):
    processed_metrics = []
    try:
        for record in event["records"]:
            pre_json_value = base64.b64decode(record['data'])
            logger.info(f"Processing")
            for line in pre_json_value.strip().splitlines():
                metric = json.loads(line)
                for key in keys_to_remove:
                    metric.pop(key,None)
                processed_metrics.append(process_metric(metric))
            if processed_metrics:
                print(processed_metrics)
                return processed_metrics
    except Exception as e:
        logger.error(f"Error processing metrics: {str(e)}")
        raise

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
            metric["tags"] = tags
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
            if bucket_name:
                return f"arn:aws-us-gov:s3:::{bucket_name}"
        elif namespace == "AWS/ES":
            domain_name = dimensions.get("DomainName")
            client_id = dimensions.get("ClientId")
            if domain_name and client_id:
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
