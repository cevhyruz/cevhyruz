#!/usr/bin/env bash

set -euo pipefail

user="${GITHUB_REPOSITORY_OWNER}"

rows=$(
  gh api --paginate "users/$user/repos?type=owner&sort=pushed&per_page=100" \
  --jq '.[]
        | select(.fork == false and .archived == false and .name != "'"$user"'")
        | "| [\(.name)](\(.html_url)) | \((.description // "-") | gsub("\\|"; "/")) | \(.language // "-") | ⭐ \(.stargazers_count) |"')

{
  sed '/<!-- REPOS:START -->/q' README.md
  echo "| Repo | Description | Language | Stars |"
  echo "|------|-------------|----------|-------|"
  echo "$rows"
  sed -n '/<!-- REPOS:END -->/,$p' README.md
} > README.new

mv README.new README.md
