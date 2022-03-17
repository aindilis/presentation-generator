#!/bin/bash

curl https://api.openai.com/v1/engines/text-davinci-001/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer " \
  -d '{"prompt": "Say this is a test", "max_tokens": 100}'
