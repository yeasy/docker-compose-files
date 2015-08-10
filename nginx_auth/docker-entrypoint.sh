#!/bin/bash
set -e
backend="${BACKEND:-web}"
port="${PORT:-80}"
username="${USERNAME:-user}"
password="${PASSWORD:-pass}"

htpasswd -c -b /etc/nginx/.htpasswd "$username" "$password"

sed "s/BACKEND/$backend/; s/PORT/$port/" /etc/nginx/nginx.default.conf > /etc/nginx/nginx.conf

nginx -c /etc/nginx/nginx.conf
