import os
import requests
import json

def lambda_handler(event, context):
    urls = json.loads(os.environ['url'])
    for url in urls:
        print(url)
        reply = requests.get(url)
        print(reply.content)
        if reply.status_code != 200:
            return reply.status_code
    return 200
