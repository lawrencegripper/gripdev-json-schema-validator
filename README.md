# GripDev Json Schema Validator

## Overview

A simple wrapper around Newtonsoft.Json.Schema as CLI or PowerShell Module.

It gives full details about the line, position, value, schemaid for any schema errors, for example:

```
{
  "Valid": false,
  "Errors": [
    {
      "Message": "String '12345' does not match regex pattern '^[0-9]{10}$'.",
      "LineNumber": 10,
      "LinePosition": 20,
      "Path": "contact.phone",
      "Value": "12345",
      "SchemaId": "#/properties/contact/properties/phone",
      "SchemaBaseUri": null,
      "ErrorType": "pattern",
      "ChildErrors": []
    }
  ]
}
```

## Installation

To install the NewtonsoftJsonSchemaTool, use the following command:

```sh
dotnet tool install --global GripDevJsonSchemaValidator
```

## Usage

To use the NewtonsoftJsonSchemaTool, run the following command:

```sh
GripDevJsonSchemaValidator <schema-file> <json-file>
```

Replace `<schema-file>` with the path to your JSON schema file and `<json-file>` with the path to your JSON file to validate.

## Example

Here is an example of how to use the NewtonsoftJsonSchemaTool:

1. Create a JSON schema file (`schema.json`):

```json
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
```

2. Create a JSON file to validate (`data.json`):

```json
{
  "name": "John Doe",
  "age": "twenty-five"
}
```

3. Run the GripDevJsonSchemaValidator:

```sh
GripDevJsonSchemaValidator schema.json data.json
```

4. The output will be a JSON array of errors with full details, including line numbers for each error:

```json
{
  "Valid": false,
  "Errors": [
    {
      "Message": "Invalid type. Expected Integer but got String.",
      "LineNumber": 3,
      "LinePosition": 12,
      "Path": "age"
    }
  ]
}
```

## Powershell Module

In addition to the dotnet CLI tool, a Powershell module is also available for running Newtonsoft schema validation on input JSON schema and files to validate. The Powershell module returns a well-typed array of error objects exposing the JSON schema validation error type.

## Installation

To install the Powershell module, use the following command:

```powershell
Install-Module -Name GripDevJsonSchemaValidator
```

## Usage

To use the Powershell module, import the module and run the `Test-JsonSchema` cmdlet:

```powershell
Import-Module GripDevJsonSchemaValidator

$errors = Test-JsonSchema -SchemaPath ./some/schema.json -JsonPath ./data.json

if ($errors.Count -eq 0) {
    Write-Output "JSON is valid."
} else {
    Write-Output "JSON is invalid. Errors:"
    $errors | ForEach-Object {
        Write-Output "Message: $_.Message"
        Write-Output "LineNumber: $_.LineNumber"
        Write-Output "LinePosition: $_.LinePosition"
        Write-Output "Path: $_.Path"
    }
}
```
