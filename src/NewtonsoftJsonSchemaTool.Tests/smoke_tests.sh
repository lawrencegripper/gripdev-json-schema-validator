#!/bin/bash

# Smoke test for NewtonsoftJsonSchemaTool CLI tool

# Define sample schema and JSON files
SCHEMA_FILE="schema.json"
JSON_FILE_VALID="data_valid.json"
JSON_FILE_INVALID="data_invalid.json"

# Create sample schema file
cat <<EOL > $SCHEMA_FILE
{
  "type": "object",
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "integer"
    }
  },
  "required": ["name", "age"]
}
EOL

# Create sample valid JSON file
cat <<EOL > $JSON_FILE_VALID
{
  "name": "John Doe",
  "age": 25
}
EOL

# Create sample invalid JSON file
cat <<EOL > $JSON_FILE_INVALID
{
  "name": "John Doe",
  "age": "twenty-five"
}
EOL

# Run the CLI tool with valid JSON file
echo "Running CLI tool with valid JSON file..."
VALID_OUTPUT=$(NewtonsoftJsonSchemaTool $SCHEMA_FILE $JSON_FILE_VALID)
echo "Output: $VALID_OUTPUT"

# Run the CLI tool with invalid JSON file
echo "Running CLI tool with invalid JSON file..."
INVALID_OUTPUT=$(NewtonsoftJsonSchemaTool $SCHEMA_FILE $JSON_FILE_INVALID)
echo "Output: $INVALID_OUTPUT"

# Validate the output for valid JSON file
if echo "$VALID_OUTPUT" | grep -q '"Valid": true'; then
  echo "Valid JSON file test passed."
else
  echo "Valid JSON file test failed."
  exit 1
fi

# Validate the output for invalid JSON file
if echo "$INVALID_OUTPUT" | grep -q '"Valid": false' && echo "$INVALID_OUTPUT" | grep -q '"Message": "Invalid type. Expected Integer but got String."'; then
  echo "Invalid JSON file test passed."
else
  echo "Invalid JSON file test failed."
  exit 1
fi

echo "All smoke tests passed."
