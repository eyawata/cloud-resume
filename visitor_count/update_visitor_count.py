# import json
# import os

# import boto3

# dynamodb = boto3.resource("dynamodb", region_name="ap-northeast-1")
# table = dynamodb.Table(os.environ["DDB_TABLE"])


# def lambda_handler(event, context):
#     counter_key = "visitor_count"

#     # Get the current value
#     response = table.get_item(Key={"counter_type": counter_key})
#     current_value = response.get("Item", {}).get("value", 0)

#     # Increment and update
#     new_value = int(current_value) + 1
#     table.put_item(Item={"counter_type": counter_key, "value": new_value})

#     return {
#         "statusCode": 200,
#         "headers": {"Content-Type": "application/json"},
#         "body": json.dumps({"visitorcount": new_value}),
#     }
