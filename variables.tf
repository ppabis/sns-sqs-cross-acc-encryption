variable "sender" {
  type        = string
  description = "AWS account ID allowed to publish, send, and describe receiver SNS/SQS resources"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.sender))
    error_message = "sender must be a 12-digit AWS account ID."
  }
}

variable "sns_subscription_email" {
  type        = string
  description = "If set, subscribe this email to the receiver SNS topic. Leave empty to skip."
  default     = ""
}

variable "receiver" {
  type        = string
  description = "AWS account ID allowed to receive, decrypt, and describe sender SNS/SQS resources"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.receiver))
    error_message = "receiver must be a 12-digit AWS account ID."
  }
}