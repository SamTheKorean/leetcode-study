#!/usr/bin/env bash

source scripts/common.bash
source scripts/leetcode_helper.bash

function main() {
  load_env_vars

  # Check if required commands are installed
  check_command "jq"
  check_command "bash"
  check_command "brew"

  # Set the required Bash version
  local required_bash_version="4.0.0"

  # Check Bash version and proceed with installation if necessary
  if check_bash_version "$required_bash_version"; then
    echo "Bash version meets the minimum requirement (>= $required_bash_version). Skipping installation."
  else
    echo "Bash version does not meet the minimum requirement (>= $required_bash_version). Proceeding with installation using Homebrew..."
    # Add your Homebrew installation commands here
    brew update
    brew install bash
  fi

  # Check if the problem title-slug or URL is provided
  if [ "$#" -eq 1 ]; then
    input="$1"
    if [[ "$input" == *"https://leetcode.com/problems/"* ]]; then
      # If the input is a LeetCode URL
      problem_slug=$(extract_problem_name "$input")
    else
      # If the input is already a title-slug
      problem_slug="$input"
    fi
  else
    echo "Please provide the LeetCode problem title-slug or URL."
    exit 1
  fi

  echo "Problem Slug: $problem_slug"

  # GraphQL query to fetch problem details
  query=$(make_query "$problem_slug")

  echo "Requesting problem details from LeetCode GraphQL API..."

  # Send a POST request to the LeetCode GraphQL API
  response=$(request "$query")

  # Check if the response contains valid data
  if ! echo -E "$response" | jq -e '.data.question' >/dev/null 2>&1; then
    echo -E "$response"
    echo "Failed to receive a valid response from the LeetCode API. Exiting the script."
    exit 1
  fi

  echo "Received problem details response from LeetCode."

  # Create the file

  create_file "$response"
}

# Call the main function
main "$@"
