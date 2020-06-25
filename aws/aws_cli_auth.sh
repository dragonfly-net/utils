#!/bin/sh -x

# Install awscli and jq first!

USER="user"
# Use AWS Account ID, not name!
AWS_ACCOUNT_ID="000000000000"

# If script fails with 'Unable to locate credentials' - run 'aws configure' and fill access_key and secret key
# if it's absent -- login to
# https://console.aws.amazon.com/iam/home?#/security_credentials
# press 'create access key' and save it. Then run 'aws configure'. Check what file '~/.aws/credentials' exists.

if [ -z "$1" ] ; then
	echo "Usage: source $0 session-token"
	exit 255
fi

SOURCE_FILE="~/source_aws"

for var in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN; do unset ${var}; done

echo "Check your devices"
aws iam list-mfa-devices --user-name ${USER}
# Just replace string in --serial-number to SerialNumber from command above
codes=$(aws sts get-session-token --serial-number "arn:aws:iam::${AWS_ACCOUNT_ID}:mfa/${USER}" --token-code $1)
echo $codes
export AWS_ACCESS_KEY_ID=$(echo $codes | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $codes | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $codes | jq -r .Credentials.SessionToken)

# fill "source" file for reuse session in other consoles
echo "export AWS_ACCESS_KEY_ID=$(echo $codes | jq -r .Credentials.AccessKeyId)" > "$SOURCE_FILE"
echo "export AWS_SECRET_ACCESS_KEY=$(echo $codes | jq -r .Credentials.SecretAccessKey) >> "$SOURCE_FILE"
echo "export AWS_SESSION_TOKEN=$(echo $codes | jq -r .Credentials.SessionToken)" >> "$SOURCE_FILE"
