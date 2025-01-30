#!/bin/bash

set -e

# Function to run the CLI tool and validate the output
run_test() {
  local test_dir=$1
  local schema_file="$test_dir/schema.json"
  local json_file="$test_dir/data.json"
  local expected_outcome_file="$test_dir/expected-outcome.json"

  echo "Running test in directory: $test_dir"
  
  # Read expected outcome
  local should_pass=$(jq -r '.shouldPass' "$expected_outcome_file")
  local expected_error=$(jq -r '.expectedError // empty' "$expected_outcome_file")

  # Run the CLI tool
  echo "Running CLI tool with JSON file: $json_file..."
  local output=$($TOOLPATH "$schema_file" "$json_file")
  echo "Output: $output"

  if echo "$output" | grep -q "\"Valid\": $should_pass"; then
    if [ "$should_pass" = "false" ] && [ ! -z "$expected_error" ]; then
      if echo "$output" | grep -q "$expected_error"; then
        echo "Test passed."
      else
        echo "Test failed. Expected error message not found."
        exit 1
      fi
    else
      echo "Test passed."
    fi
  else
    echo "Test failed. Expected valid: $should_pass"
    exit 1
  fi
}

cd "$(dirname "$0")"
cd ..

echo "Publishing CLI tool"
dotnet publish -c Release -r linux-x64 -p:PublishSingleFile=true 

TOOLPATH=bin/Release/net8.0/linux-x64/publish/GripDevJsonSchemaValidator

# Run all tests by walking the smoke-test directory
for test_dir in smoke-test/*; do
  if [ -d "$test_dir" ]; then
    run_test "$test_dir"
  fi
done

echo "All smoke tests passed."
