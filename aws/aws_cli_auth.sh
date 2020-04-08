#!/bin/sh

USER="user"
# Use AWS Account ID, not name!
AWS_ACCOUNT_ID="000000000000"

if [ -z "$1" ] ; then
	echo "Usage: source $0 session-token"
	exit 255
fi

for var in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN; do unset ${var}; done

echo "Check your devices"
aws iam list-mfa-devices --user-name ${USER}
# Just replace string in --serial-number to SerialNumber from command above
codes=$(aws sts get-session-token --serial-number "arn:aws:iam::${AWS_ACCOUNT_ID}:mfa/${USER}" --token-code $1)
echo $codes
export AWS_ACCESS_KEY_ID=$(echo $codes | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $codes | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $codes | jq -r .Credentials.SessionToken)

