# GripDev Json Schema Validator

## Overview

A simple wrapper around Newtonsoft.Json.Schema as CLI or PowerShell Module.

It gives full details about the line, position, value, schemaid for any schema errors

As JSON scripts:

```
{
  "Valid": false,
  "Errors": [
    {
      "UserMessage": "\n❌ Error Details:\n   └─ Message: Required properties are missing from object: city.\n   └─ Location: Line 4, Position 14\n   └─ Path: address\n   └─ "
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

Or Pretty printed output for users 👀 even handling `if-then-else` and sub errors nicely!

```
 ❌ Error Details:
   └─ Message: JSON does not match schema from 'then'.
   └─ Location: Line 151, Position 14
   └─ Path: mingw
   └─ Value: 
   └─ Related Issues:
      ↳ Required properties are missing from object: pinnedDetails.
```

You can easily use this to output annotations onto files during Pull Requests, for example, with GitHub Actions. The `Write-Host ::error` line tells actions to add an annotation with the user message to the right file and line.

```pwsh
    $validationResult = Test-JsonSchema -SchemaPath $schemaFilePath -JsonPath $file.FullName -PrettyPrint $false

    if ($validationResult.Valid) {
        Write-Host "✅ JSON is valid." -ForegroundColor Green
    } else {
        # File has been modified since the commit, enforce validation
        $toolsetHasErrors = $true
        Write-Host "`n❌ JSON validation failed!" -ForegroundColor Red
        Write-Host "   Found the following errors:`n" -ForegroundColor Yellow

        $validationResult.Errors | ForEach-Object {
            Write-Host $_.UserMessage
            if ($env:GITHUB_ACTIONS -eq 'true') {
                Write-Host "Adding annotation"
                Write-Host "::error file=$($file.Name),line=$($_.LineNumber)::$($_.UserMessage.Replace("`n", '%0A'))"
            }
        }
    }
```

Big shout out to [James King (Newtonsoft)](https://www.newtonsoft.com/jsonschema) for the heavy lifting here using the [AGPL version of his library](https://www.nuget.org/packages/Newtonsoft.Json.Schema/4.0.1/License). See pricing for non agpl version on their site.

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

$validationResult = Test-JsonSchema -SchemaPath ./some/schema.json -JsonPath ./data.json

if ($validationResult.Valid) {
    Write-Output "JSON is valid."
} else {
    Write-Output "JSON is invalid. Errors:"
    $validationResult.Errors | ForEach-Object {
        Write-Output "Message: $($_.Message)"
        if ($_.ChildErrors) {
            $_.ChildErrors | ForEach-Object {
                Write-Output "  Child Error: $($_.Message)"
            }
        }
        Write-Output "LineNumber: $($_.LineNumber)"
        Write-Output "LinePosition: $($_.LinePosition)"
        Write-Output "Path: $($_.Path)"
        Write-Output "Value: $($_.Value)"
    }
}
```

