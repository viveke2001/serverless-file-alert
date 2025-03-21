import json
import boto3
import os

sns_client = boto3.client("sns")

def lambda_handler(event, context):
    # Extract bucket name and file name from the event
    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        file_name = record['s3']['object']['key']
        event_time = record['eventTime']

        # Format message
        message = f"""
         File Upload Alert 
        
         A new file has been uploaded to S3!
        
         File Name: {file_name}
         Bucket Name: {bucket_name}
         Timestamp: {event_time}
        
        Check your S3 bucket for details.
        """

        # Publish the message to SNS Topic
        response = sns_client.publish(
            TopicArn=os.environ['SNS_TOPIC_ARN'],
            Message=message,
            Subject=" New File Uploaded to S3!"
        )

    return {
        "statusCode": 200,
        "body": json.dumps("SNS Notification Sent Successfully!")
    }
