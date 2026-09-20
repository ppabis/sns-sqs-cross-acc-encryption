resource "random_pet" "provision" {
  prefix    = "sns-sqs-encrypt"
  separator = "-"
  length    = 2
}
