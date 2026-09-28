resource "aws_cloudwatch_metric_alarm" "sqs_visible" {
  provider = aws.receiver

  alarm_name          = "${aws_sqs_queue.this.name}-visible-messages"
  alarm_description   = "Visible messages in the receiver SQS queue are greater than 5"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Maximum"
  threshold           = 5
  alarm_actions       = [aws_sns_topic.cloudwatch.arn]

  dimensions = {
    QueueName = aws_sqs_queue.this.name
  }
}

resource "aws_sns_topic" "cloudwatch" {
  provider = aws.receiver

  name              = "${aws_sqs_queue.this.name}-visible-messages"
  kms_master_key_id = aws_kms_alias.sns.name
}

data "aws_iam_policy_document" "sns_cloudwatch" {
  provider = aws.receiver

  statement {
    sid    = "AllowCloudWatch"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.cloudwatch.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.receiver.account_id]
    }
  }
}

resource "aws_sns_topic_policy" "cloudwatch" {
  provider = aws.receiver

  arn    = aws_sns_topic.cloudwatch.arn
  policy = data.aws_iam_policy_document.sns_cloudwatch.json
}

resource "aws_sns_topic_subscription" "cloudwatch" {
  provider = aws.receiver
  count    = var.sns_subscription_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.cloudwatch.arn
  protocol  = "email"
  endpoint  = var.sns_subscription_email
}
