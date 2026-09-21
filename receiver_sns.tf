resource "aws_sns_topic" "this" {
  provider = aws.receiver

  name              = random_pet.provision.id
  kms_master_key_id = aws_kms_alias.sns.name
}

data "aws_iam_policy_document" "sns" {
  provider = aws.receiver

  statement {
    sid    = "AllowSenderAccount"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.sender}:root"]
    }

    actions = [
      "sns:Publish",
      "sns:GetTopicAttributes",
    ]

    resources = [aws_sns_topic.this.arn]
  }
}

resource "aws_sns_topic_policy" "this" {
  provider = aws.receiver

  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.sns.json
}

resource "aws_sns_topic_subscription" "email" {
  provider = aws.receiver
  count    = var.sns_subscription_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.sns_subscription_email
}
