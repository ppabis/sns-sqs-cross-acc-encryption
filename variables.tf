variable "sender" {
  type        = string
  description = "AWS account ID allowed to publish, send, and describe receiver SNS/SQS resources"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.sender))
    error_message = "sender must be a 12-digit AWS account ID."
  }
}
