#!/bin/bash

if [ $# -ne 2 ] || \
   [ "$AWS_ACCESS_KEY_ID" == "" ] || \
   [ "$AWS_SECRET_ACCESS_KEY" == "" ] || \
   [ "$AWS_DEFAULT_REGION" == "" ] || \
   [ "$AWS_S3_BUCKET" == "" ] || \
   [ "$(which aws)" == "" ]
then
    echo "Usage $0 <stack name> <template file>"
    echo
    echo "<stack name> - The name of the stack to update"
    echo "<template file> - The stack template"
    echo
    echo "The following environnment variables must be set for this script to function:"
    echo "    AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, AWS_S3_BUCKET"
    echo
    echo "The AWS CLI (https://aws.amazon.com/cli/) must be installed and in your \$PATH"
    exit 1
fi

##### SETTINGS

# the name of our stack
STACK_NAME="$1"

# s3 urls
S3_BASE="https://s3-${AWS_DEFAULT_REGION}.amazonaws.com"

# folder in the bucket
VERSION="dev"

# the top level cloud formation template
TOP="$2"

# bail if anything goes wrong
set -e

# check to see if the stack exists
LAST_UPDATED=$(
    set -o pipefail;
    aws cloudformation describe-stacks --stack-name $STACK_NAME | jq .Stacks[0].LastUpdatedTime
)
echo "Updating $STACK_NAME; Last Update: $LAST_UPDATED"

# copy the json up to s3
aws s3 cp "$TOP" s3://$AWS_S3_BUCKET/$VERSION/
for i in templates/*.json; do
    aws s3 cp "$i" s3://$AWS_S3_BUCKET/$VERSION/
done

# create the change set, using the parameters from the last version
aws cloudformation update-stack \
    --stack-name $STACK_NAME \
    --template-url $S3_BASE/$AWS_S3_BUCKET/$VERSION/$TOP \
    --parameters "$(aws cloudformation describe-stacks \
                    --stack-name $STACK_NAME \
                    | jq .Stacks[0].Parameters \
                    | jq 'map(. + {"UsePreviousValue": true, "ParameterValue": ""})' \
                    | jq '. + [{"UsePreviousValue": false, "ParameterKey":"S3Path", "ParameterValue": "'"$S3_BASE/$AWS_S3_BUCKET/$VERSION"'"}]' \
                    )"


# loop until execution has finished
STATE="IN_PROGRESS"
EVENT_ID=""
while [[ $STATE == *"IN_PROGRESS"* ]]; do
    NEW_STATE=$(aws cloudformation describe-stacks \
                --stack-name $STACK_NAME | jq .Stacks[0].StackStatus)

    # if our state changes, log it
    if [ "$NEW_STATE" != "$STATE" ]; then
        echo "update-stack: $STATE"
        STATE="$NEW_STATE"
    fi

    # a single execute-change-set can generate dozens of events
    # poll for new events and print them as they occur
    LATEST_EVENT=$(aws cloudformation describe-stack-events \
                   --stack-name $STACK_NAME | jq .StackEvents[0])
    LATEST_EVENT_ID=$(echo $LATEST_EVENT | jq .EventId)

    if [ "$LATEST_EVENT_ID" != "$EVENT_ID" ]; then
        echo $LATEST_EVENT | jq .
        EVENT_ID="$LATEST_EVENT_ID"
    fi

    sleep 1
done

# we are done, show the last event and our final state
aws cloudformation describe-stacks --stack-name $STACK_NAME | jq .
