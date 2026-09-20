data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "this" {
  provider = aws.sender

  function_name    = "sns-sqs-encrypt"
  role             = aws_iam_role.lambda.arn
  handler          = "main.handler"
  runtime          = "python3.13"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.this.arn
      SQS_QUEUE_URL = aws_sqs_queue.this.url
    }
  }
}
