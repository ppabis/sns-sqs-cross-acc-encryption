data "aws_caller_identity" "receiver" {
  provider = aws.receiver
}

data "aws_iam_policy_document" "kms" {
  provider = aws.receiver

  statement {
    sid       = "EnableOwnAccount"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.receiver.account_id}:root"]
    }
  }

  statement {
    sid    = "AllowSenderAccount"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.sender}:root"]
    }
  }

  statement {
    sid    = "AllowCloudWatchAndEvents"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt",
    ]
    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
        "events.amazonaws.com",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.receiver.account_id]
    }
  }
}

resource "aws_kms_key" "sns" {
  provider = aws.receiver

  description             = "SNS Key for ${random_pet.provision.id}"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.kms.json
}

resource "aws_kms_alias" "sns" {
  provider = aws.receiver

  name          = "alias/sns-${random_pet.provision.id}"
  target_key_id = aws_kms_key.sns.id
}
