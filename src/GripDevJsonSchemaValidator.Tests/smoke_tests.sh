#!/bin/bash

# Smoke test for GripDevJsonSchemaValidator CLI tool

# Define sample schema and JSON files
SCHEMA_FILES=("schema1.json" "schema2.json" "schema3.json")
JSON_FILES_VALID=("data_valid1.json" "data_valid2.json" "data_valid3.json")
JSON_FILES_INVALID=("data_invalid1.json" "data_invalid2.json" "data_invalid3.json")

# Create sample schema files
cat <<EOL > ${SCHEMA_FILES[0]}
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

cat <<EOL > ${SCHEMA_FILES[1]}
{
  "type": "object",
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "integer"
    },
    "address": {
      "type": "object",
      "properties": {
        "street": {
          "type": "string"
        },
        "city": {
          "type": "string"
        }
      },
      "required": ["street", "city"]
    }
  },
  "required": ["name", "age", "address"]
}
EOL

cat <<EOL > ${SCHEMA_FILES[2]}
{
  "type": "object",
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "integer"
    },
    "address": {
      "type": "object",
      "properties": {
        "street": {
          "type": "string"
        },
        "city": {
          "type": "string"
        }
      },
      "required": ["street", "city"]
    },
    "contact": {
      "type": "object",
      "properties": {
        "email": {
          "type": "string",
          "format": "email"
        },
        "phone": {
          "type": "string",
          "pattern": "^[0-9]{10}$"
        }
      },
      "required": ["email", "phone"]
    }
  },
  "required": ["name", "age", "address", "contact"]
}
EOL

# Create sample valid JSON files
cat <<EOL > ${JSON_FILES_VALID[0]}
{
  "name": "John Doe",
  "age": 25
}
EOL

cat <<EOL > ${JSON_FILES_VALID[1]}
{
  "name": "John Doe",
  "age": 25,
  "address": {
    "street": "123 Main St",
    "city": "Anytown"
  }
}
EOL

cat <<EOL > ${JSON_FILES_VALID[2]}
{
  "name": "John Doe",
  "age": 25,
  "address": {
    "street": "123 Main St",
    "city": "Anytown"
  },
  "contact": {
    "email": "john.doe@example.com",
    "phone": "1234567890"
  }
}
EOL

# Create sample invalid JSON files
cat <<EOL > ${JSON_FILES_INVALID[0]}
{
  "name": "John Doe",
  "age": "twenty-five"
}
EOL

cat <<EOL > ${JSON_FILES_INVALID[1]}
{
  "name": "John Doe",
  "age": 25,
  "address": {
    "street": "123 Main St"
  }
}
EOL

cat <<EOL > ${JSON_FILES_INVALID[2]}
{
  "name": "John Doe",
  "age": 25,
  "address": {
    "street": "123 Main St",
    "city": "Anytown"
  },
  "contact": {
    "email": "john.doe@example",
    "phone": "12345"
  }
}
EOL

# Function to run the CLI tool and validate the output
run_test() {
  local schema_file=$1
  local json_file=$2
  local expected_valid=$3
  local expected_message=$4

  echo "Running CLI tool with JSON file: $json_file..."
  local output=$(GripDevJsonSchemaValidator $schema_file $json_file)
  echo "Output: $output"

  if echo "$output" | grep -q "\"Valid\": $expected_valid"; then
    if [ "$expected_valid" = "false" ]; then
      if echo "$output" | grep -q "$expected_message"; then
        echo "Test passed."
      else
        echo "Test failed. Expected message not found."
        exit 1
      fi
    else
      echo "Test passed."
    fi
  else
    echo "Test failed. Expected valid: $expected_valid"
    exit 1
  fi
}

# Run tests for valid JSON files
for i in "${!JSON_FILES_VALID[@]}"; do
  run_test "${SCHEMA_FILES[$i]}" "${JSON_FILES_VALID[$i]}" "true" ""
done

# Run tests for invalid JSON files
run_test "${SCHEMA_FILES[0]}" "${JSON_FILES_INVALID[0]}" "false" "Invalid type. Expected Integer but got String."
run_test "${SCHEMA_FILES[1]}" "${JSON_FILES_INVALID[1]}" "false" "Required properties are missing from object: city."
run_test "${SCHEMA_FILES[2]}" "${JSON_FILES_INVALID[2]}" "false" "Invalid email format. Invalid phone number format."

echo "All smoke tests passed."
