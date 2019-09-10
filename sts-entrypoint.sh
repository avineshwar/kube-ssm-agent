#!/bin/bash
set -e

# workaround SSM Agent issue https://github.com/aws/amazon-ssm-agent/issues/211 (vendoring AWS Go SDK without OIDC support)
# assume role with web identity using AWS CLI
echo "Assuming role with AWS STS (duration=12h) ..."

aws sts assume-role-with-web-identity \
 --role-arn $AWS_ROLE_ARN \
 --role-session-name mh9test \
 --web-identity-token file://$AWS_WEB_IDENTITY_TOKEN_FILE \
 --duration-seconds 43200 > /tmp/cred.txt

export AWS_ACCESS_KEY_ID="$(cat /tmp/cred.txt | jq -r ".Credentials.AccessKeyId")"
export AWS_SECRET_ACCESS_KEY="$(cat /tmp/cred.txt | jq -r ".Credentials.SecretAccessKey")"
export AWS_SESSION_TOKEN="$(cat /tmp/cred.txt | jq -r ".Credentials.SessionToken")"

rm /tmp/cred.txt

exec "$@"