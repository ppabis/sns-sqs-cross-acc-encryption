resource "aws_sqs_queue" "from_default_kms" {
  provider = aws.receiver

  name = "${random_pet.provision.id}-from-default-kms"
}

resource "aws_sqs_queue" "from_custom_kms" {
  provider = aws.receiver

  name = "${random_pet.provision.id}-from-custom-kms"
}

resource "aws_sns_topic_subscription" "from_default_kms" {
  provider = aws.receiver

  topic_arn = aws_sns_topic.default_kms_sender.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.from_default_kms.arn
}

resource "aws_sns_topic_subscription" "from_custom_kms" {
  provider = aws.receiver

  topic_arn = aws_sns_topic.custom_kms_sender.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.from_custom_kms.arn
}

data "aws_iam_policy_document" "sns_publish_to_sqs" {
  provider = aws.receiver

  statement {
    actions   = ["sqs:SendMessage"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.sender]
    }
  }
}

resource "aws_sqs_queue_policy" "from_default_kms" {
  provider = aws.receiver

  queue_url = aws_sqs_queue.from_default_kms.id
  policy    = data.aws_iam_policy_document.sns_publish_to_sqs.json
}

resource "aws_sqs_queue_policy" "from_custom_kms" {
  provider = aws.receiver

  queue_url = aws_sqs_queue.from_custom_kms.id
  policy    = data.aws_iam_policy_document.sns_publish_to_sqs.json
}

output "from_default_kms_queue_url" {
  value = aws_sqs_queue.from_default_kms.url
}

output "from_custom_kms_queue_url" {
  value = aws_sqs_queue.from_custom_kms.url
}