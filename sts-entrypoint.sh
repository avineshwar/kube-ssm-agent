#!/bin/bash
set -e

# workaround SSM Agent issue https://github.com/aws/amazon-ssm-agent/issues/211 (vendoring AWS Go SDK without OIDC support)
# assume role with web identity using AWS CLI
# echo "Assuming role with AWS STS (duration=1h) ..."

aws sts assume-role-with-web-identity \
 --role-arn $AWS_ROLE_ARN \
 --role-session-name mh9test \
 --web-identity-token file://$AWS_WEB_IDENTITY_TOKEN_FILE \
 --duration-seconds 3600 > /tmp/cred.txt

AWS_ACCESS_KEY_ID="$(cat /tmp/cred.txt | jq -r ".Credentials.AccessKeyId")"
AWS_SECRET_ACCESS_KEY="$(cat /tmp/cred.txt | jq -r ".Credentials.SecretAccessKey")"
AWS_SESSION_TOKEN="$(cat /tmp/cred.txt | jq -r ".Credentials.SessionToken")"

mkdir -p /home/ssm-user/.aws

cat << EOF > /home/ssm-user/.aws/credentials
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
aws_session_token = ${AWS_SESSION_TOKEN}
EOF

exec "$@"