import json
import os

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    greeting = json.loads(os.environ['text'])
    template = """<!DOCTYPE html>
<html>
  <head>
    <title>Title</title>
  </head>
  <body>
    <h1>__TEXT__</h1>
  </body>
</html>
"""
    if 'name' in event['queryStringParameters']:
        text = greeting + event['queryStringParameters']['name']
        return {
            "statusCode": 200,
                "headers": {'Content-Type': 'text/html'},
                "body": template.replace("__TEXT__", text)
            }
    return {
        "statusCode": 500,
            "headers": {'Content-Type': 'text/html'},
            "body": template.replace("__TEXT__", "Bad request")
        }