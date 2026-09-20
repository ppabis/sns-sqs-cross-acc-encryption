resource "aws_sqs_queue" "this" {
  provider = aws.receiver

  name                    = random_pet.provision.id
  sqs_managed_sse_enabled = false
}

data "aws_iam_policy_document" "sqs" {
  provider = aws.receiver

  statement {
    sid    = "AllowSenderAccount"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.sender}:root"]
    }

    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]

    resources = [aws_sqs_queue.this.arn]
  }
}

resource "aws_sqs_queue_policy" "this" {
  provider = aws.receiver

  queue_url = aws_sqs_queue.this.id
  policy    = data.aws_iam_policy_document.sqs.json
}
