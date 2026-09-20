resource "aws_sns_topic" "this" {
  provider = aws.receiver

  name = random_pet.provision.id
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
