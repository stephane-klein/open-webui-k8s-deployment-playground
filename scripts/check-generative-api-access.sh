#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

curl https://api.scaleway.ai/${TF_VAR_openwebui_project_id}/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TF_VAR_scaleway_generative_api_secret_key}" \
    -d '{
        "model": "llama-3.1-8b-instruct",
        "messages": [
            { "role": "system", "content": "You are a helpful assistant" },
			{ "role": "user", "content": "De quel couleur est le soleil ?" }
        ],
        "max_tokens": 512,
        "temperature": 0.6,
        "top_p": 0.9,
        "presence_penalty": 0,
        "stream": true
    }'
