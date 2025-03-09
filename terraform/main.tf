# S3 Bucket
resource "aws_s3_bucket" "file_bucket" {
  bucket = "serverless-file-alert-bucket"
}

# SNS Topic for Email Alerts
resource "aws_sns_topic" "file_alerts" {
  name = "file-upload-alerts"
}

# SNS Subscription (Email)
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.file_alerts.arn
  protocol  = "email"
  endpoint  = "evreddy072001@gmail.com"  
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Attach Policies to Lambda Role
resource "aws_iam_policy_attachment" "lambda_policy" {
  name       = "lambda_policy_attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "file_alert_function" {
  function_name = "FileAlertFunction"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  filename      = "lambda_function.zip"
  timeout       = 10

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.file_alerts.arn
    }
  }
}

# S3 Event Trigger for Lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.file_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.file_alert_function.arn
    events             = ["s3:ObjectCreated:*"]
  }
}

# Allow S3 to Trigger Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_alert_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.file_bucket.arn
}
