#
# Load Lambda code
#
resource "aws_s3_bucket" "lambda_bucket_temporaney" {
  bucket = "mock-ec-${var.env_short}"

  acl           = "private"
  force_destroy = true
}

data "archive_file" "lambda_mock_archive_file" {
  type = "zip"

  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_s3_object" "lambda_mock_archive_file" {
  bucket = aws_s3_bucket.lambda_bucket_temporaney.id

  key    = "lambda.zip"
  source = data.archive_file.lambda_mock_archive_file.output_path

  etag = filemd5(data.archive_file.lambda_mock_archive_file.output_path)
}

#
# Create Lambda function
#
resource "aws_lambda_function" "mock_ec" {
  function_name = "mock-ec-${var.env_short}-lambda"

  s3_bucket = aws_s3_bucket.lambda_bucket_temporaney.id
  s3_key    = aws_s3_object.lambda_mock_archive_file.key

  runtime = "nodejs16.x"
  handler = "mock-ec.handler"

  source_code_hash = data.archive_file.lambda_mock_archive_file.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function_url" "mock_ec_latest" {
  function_name      = aws_lambda_function.mock_ec.function_name
  authorization_type = "NONE"
}

resource "aws_cloudwatch_log_group" "mock_ec" {
  name = "/aws/lambda/${aws_lambda_function.mock_ec.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
