$ErrorActionPreference = "Debug"

# Load Newtonsoft assemblies from the same directory as this script
$scriptPath = $PSScriptRoot
Add-Type -Path (Join-Path $scriptPath "Newtonsoft.Json.dll")
Add-Type -Path (Join-Path $scriptPath "Newtonsoft.Json.Schema.dll")


function Test-JsonSchema {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SchemaPath,

        [Parameter(Mandatory = $true)]
        [string]$JsonPath
    )

    $schemaContent = Get-Content -Path $SchemaPath -Raw
    $jsonContent = Get-Content -Path $JsonPath -Raw

    $schema = [Newtonsoft.Json.Schema.JSchema]::Parse($schemaContent)
    
    $errors = New-Object System.Collections.Generic.List[Newtonsoft.Json.Schema.ValidationError]

    $valid = [NewtonSoft.Json.Schema.SchemaExtensions]::IsValid($jsonContent, $schema, [ref]$errors)

    $errorDetails = [System.Collections.Generic.List[PSCustomObject]]::new()
    foreach ($error in $errors) {
        $errorDetails += [PSCustomObject]@{
            Message       = $error.Message
            LineNumber    = $error.LineNumber
            LinePosition  = $error.LinePosition
            Path          = $error.Path
            Value         = $error.Value
            Schema        = $error.Schema
            SchemaId      = $error.SchemaId
            SchemaBaseUri = $error.SchemaBaseUri
            ErrorType     = $error.ErrorType
            ChildErrors   = $error.ChildErrors
        }
    }

    return [PSCustomObject]@{
        Valid  = $valid
        Errors = $errorDetails
    }
}
