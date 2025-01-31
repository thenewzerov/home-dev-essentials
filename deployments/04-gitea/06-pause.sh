#!/bin/bash

# URL to check
URL="https://gitea.${APPLICATIONS_GLOBAL_BASE_URL}"

# Time to wait between checks (in seconds)
WAIT_TIME=10

check_website() {
  echo "Waiting for Gitea..."

  # Use curl to check the webpage and capture the HTTP status code
  HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" "$URL")

  # Check if the HTTP status code is 200
  if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "Gitea is now available."
    return 0
  else
    echo "Gitea is not available (HTTP status code: $HTTP_STATUS). Waiting for $WAIT_TIME seconds..."
    sleep $WAIT_TIME
    return 1
  fi
}

# Loop until the webpage is available
until check_website; do :; done