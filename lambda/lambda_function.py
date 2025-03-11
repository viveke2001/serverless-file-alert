import json
import boto3
import os

sns_client = boto3.client("sns")

def lambda_handler(event, context):
    print("Event received:", json.dumps(event))
    
    # Extract file name from S3 event
    records = event.get("Records", [])
    if not records:
        return {"statusCode": 400, "body": "No records found"}
    
    for record in records:
        bucket_name = record["s3"]["bucket"]["name"]
        file_name = record["s3"]["object"]["key"]
        
        message = f"New file uploaded: {file_name} in bucket {bucket_name}"
        print(message)
        
        # Send SNS email notification
        sns_client.publish(
            TopicArn=os.environ["SNS_TOPIC_ARN"],
            Message=message,
            Subject="File Upload Alert"
        )
    
    return {"statusCode": 200, "body": "Notification sent"}
