data "aws_iam_policy_document" "lambda_assume_role" {
  provider = aws.sender

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_messaging" {
  provider = aws.sender

  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:GetTopicAttributes",
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "lambda" {
  provider = aws.sender

  name               = "sns-sqs-encrypt-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy" "lambda_messaging" {
  provider = aws.sender

  name   = "sns-sqs-encrypt-messaging"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_messaging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  provider = aws.sender

  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
