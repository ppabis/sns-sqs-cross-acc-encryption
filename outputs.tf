output "lambda_function_name" {
  description = "Sender Lambda function name"
  value       = aws_lambda_function.this.function_name
}

output "sqs_queue_url" {
  description = "Receiver SQS queue URL"
  value       = aws_sqs_queue.this.url
}
