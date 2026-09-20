import logging
import os
from datetime import datetime, timezone

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

sns = boto3.client("sns")
sqs = boto3.client("sqs")

SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
SQS_QUEUE_URL = os.environ["SQS_QUEUE_URL"]


def handler(event, context):
    try:
        now = datetime.now(timezone.utc)
        message = f"{now:%A}, {now.day} {now:%B %Y} at {now:%H:%M} UTC"

        message_sqs = f"Lambda to SQS: {message}"
        message_sns = f"Lambda to SNS: {message}"

        sqs.send_message(QueueUrl=SQS_QUEUE_URL, MessageBody=message)
        sns.publish(TopicArn=SNS_TOPIC_ARN, Message=message)

        return {"statusCode": 200, "body": message}
    except Exception as e:
        logger.exception("failed to send message")
        return {"statusCode": 500, "body": str(e)}
