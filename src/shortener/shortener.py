import os
import json
import logging
import uuid
import boto3
from botocore.exceptions import ClientError

s3_client = boto3.client('s3')

bucket = os.getenv("SHORTENER_BUCKET","")

def upload_file(file_name, bucket, object_name, url):

    try:            
        s3_client.upload_file(
            file_name, bucket, object_name,
            ExtraArgs={'WebsiteRedirectLocation': url} 
        )
        os.remove(file_name)
    except ClientError as e:
        logging.error(e)
        return None

    return f"https://{bucket}/{file_name}"

def shorten_url(url, app):

    while True:
        try:
            file_name = uuid.uuid4().hex[:10]
            object_name = file_name
            s3_client.head_object(Bucket=bucket, Key=file_name)
        except ClientError as e:
            if e.response['Error']['Code'] == "404":
                with open(file_name, "w") as f:
                    content = {
                        "file_name": file_name,
                        "url": url,
                        "app": app,
                    }
                    f.write(json.dumps(content))
                    return upload_file(file_name, bucket, object_name, url)
            else:
                logging.error(e)
                raise e
            