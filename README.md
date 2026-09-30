AWS SQS and SNS encryption shenanigans
================

This project demonstrates how to deal with AWS SQS and SNS encryption when
exposing the services for cross-account access or using across AWS services.

It demonstrates what configurations require custom KMS key with appropriate
permissions or can reuse the default key.

Follow this blog post if you would like to learn more:

- [`on pabis.eu`](https://pabis.eu/blog/2026-09-29-Insanity-of-SNS-encryption.html)
- [`on dev.to`](https://dev.to/aws-builders/sns-encryption-drives-me-insane-57l5)
