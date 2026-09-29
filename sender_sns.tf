resource "aws_sns_topic" "default_kms_sender" {
  provider = aws.sender

  name              = "${random_pet.provision.id}-sender-default-kms"
  kms_master_key_id = "alias/aws/sns"
}


resource "aws_kms_key" "sender_sns" {
  provider = aws.sender

  description             = "SNS Key for ${random_pet.provision.id} sender-custom-kms"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.sender_sns_kms.json
}

resource "aws_kms_alias" "sender_sns" {
  provider = aws.sender

  name          = "alias/sns-${random_pet.provision.id}-sender"
  target_key_id = aws_kms_key.sender_sns.id
}

resource "aws_sns_topic" "custom_kms_sender" {
  provider = aws.sender

  name              = "${aws_sqs_queue.this.name}-sender-custom-kms"
  kms_master_key_id = aws_kms_alias.sender_sns.name
}

data "aws_iam_policy_document" "sender_sns" {
  provider = aws.sender

  statement {
    actions = ["sns:Subscribe"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.receiver}:root"]
    }
    resources = ["arn:aws:sns:*:${var.sender}:*"]
  }
}

resource "aws_sns_topic_policy" "default_kms_sender" {
  provider = aws.sender

  arn    = aws_sns_topic.default_kms_sender.arn
  policy = data.aws_iam_policy_document.sender_sns.json
}

resource "aws_sns_topic_policy" "custom_kms_sender" {
  provider = aws.sender

  arn    = aws_sns_topic.custom_kms_sender.arn
  policy = data.aws_iam_policy_document.sender_sns.json
}

data "aws_iam_policy_document" "sender_sns_kms" {
  provider = aws.sender

  statement {
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.sender}:root"]
    }
    resources = ["*"]
  }
}

output "custom_kms_sender_topic_arn" {
  value = aws_sns_topic.custom_kms_sender.arn
}

output "default_kms_sender_topic_arn" {
  value = aws_sns_topic.default_kms_sender.arn
}