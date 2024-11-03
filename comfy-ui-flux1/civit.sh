#!/bin/bash

# Check if CIVITAI_TOKEN is set, if not prompt the user for their API token
if [ -z "$CIVITAI_TOKEN" ]; then
  read -p "Enter your API token: " api_token
  export CIVITAI_TOKEN=$api_token
fi
# Prompt the user for the model ID
read -p "Enter the model ID: " model_id

# Prompt the user for the model location
read -p "Enter the model location: " model_location



# Construct the URL for the GET request
url=https://civitai.com/api/download/models/${model_id}?token=${api_token}
# Use wget to download the file
wget -O "${model_location}" "${url}"

echo "Done..."
