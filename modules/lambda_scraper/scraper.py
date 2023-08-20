import os
import requests
import json

def lambda_handler(event, context):
    url = os.environ['url']
    print(url)
    reply = requests.get(url)
    print(reply.content)
    return reply.status_code