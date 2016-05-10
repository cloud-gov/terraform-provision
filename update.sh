#!/bin/bash

if [ $# -eq 0 ] || \
   [ "$AWS_ACCESS_KEY_ID" == "" ] || \
   [ "$AWS_SECRET_ACCESS_KEY" == "" ] || \
   [ "$AWS_DEFAULT_REGION" == "" ] || \
   [ "$(which aws)" == "" ]
then
    echo "Usage $0 <stack name>"
    echo
    echo "<stack name> - The name of the stack to update"
    echo
    echo "The following environnment variables must be set for this script to function:"
    echo "    AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION"
    echo
    echo "The AWS CLI (https://aws.amazon.com/cli/) must be installed and in your \$PATH"
    exit 1
fi

##### SETTINGS

# the name of our stack
STACK_NAME="$1"

# s3 urls
S3_BASE="https://s3-${AWS_DEFAULT_REGION}.amazonaws.com"

# the bucket
BUCKET="cf-templates-1v2czdpr8i6tw-us-gov-west-1"

# folder in the bucket
VERSION="dev"

# the top level cloud formation template
TOP="vpc.json"

# bail if anything goes wrong
set -e

# check to see if the stack exists
LAST_UPDATED=$(
    set -o pipefail; 
    aws cloudformation describe-stacks --stack-name $STACK_NAME | jq .Stacks[0].LastUpdatedTime
)
echo "Updating $STACK_NAME; Last Update: $LAST_UPDATED"

# copy the json up to s3
for i in *.json; do aws s3 cp "$i" s3://$BUCKET/$VERSION/; done

# generate a random change set name
CS_NAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# create the change set, using the parameters from the last version
aws cloudformation create-change-set \
    --stack-name $STACK_NAME \
    --change-set-name "$CS_NAME" \
    --template-url $S3_BASE/$BUCKET/$VERSION/$TOP \
    --parameters "$(aws cloudformation describe-stacks \
                    --stack-name $STACK_NAME | jq .Stacks[0].Parameters \
                    )" &>/dev/null

# loop until the change-set is complete or has failed
STATE="IN_PROGRESS"
while [[ $STATE == *"IN_PROGRESS"* ]]; do
    NEW_STATE=$(aws cloudformation describe-change-set \
                --stack-name $STACK_NAME \
                --change-set-name "$CS_NAME" | jq .Status)
    
    # if our state changes, log it
    if [ "$NEW_STATE" != "$STATE" ]; then
        echo "create-change-set($CS_NAME): $STATE"
        STATE="$NEW_STATE"
    fi

    sleep 1
done

# show them the output
aws cloudformation describe-change-set --stack-name $STACK_NAME --change-set-name "$CS_NAME" | jq .

# if we've failed, then there's nothing else to do so bounce
if [[ $STATE == *"FAILED"* ]]; then
    exit 1;
fi

# make sure we want to do this?
read -p "Deploy these changes? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# execute the change set
aws cloudformation execute-change-set --stack-name $STACK_NAME --change-set-name "$CS_NAME"

# loop until execution has finished
STATE="IN_PROGRESS"
EVENT_ID=""
while [[ $STATE == *"IN_PROGRESS"* ]]; do
    NEW_STATE=$(aws cloudformation describe-stacks \
                --stack-name $STACK_NAME | jq .Stacks[0].StackStatus)
    
    # if our state changes, log it
    if [ "$NEW_STATE" != "$STATE" ]; then
        echo "execute-change-set($CS_NAME): $STATE"
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
