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
        [string]$JsonPath,

        [Parameter(Mandatory = $false)]
        [bool]$PrettyPrint = $true
    )

    $schemaContent = Get-Content -Path $SchemaPath -Raw
    $jsonContent = Get-Content -Path $JsonPath -Raw

    $schema = [Newtonsoft.Json.Schema.JSchema]::Parse($schemaContent)
    
    $errors = New-Object System.Collections.Generic.List[Newtonsoft.Json.Schema.ValidationError]

    $valid = [NewtonSoft.Json.Schema.SchemaExtensions]::IsValid($jsonContent, $schema, [ref]$errors)

    $userErrorMessages = @()
    
    if ($valid) {
        if ($PrettyPrint) { Write-Host "✅ JSON is valid." -ForegroundColor Green }
    }
    else {
        if ($PrettyPrint) { Write-Host "`n❌ JSON validation failed!" -ForegroundColor Red }
        if ($PrettyPrint) { Write-Host "   Found the following errors:`n" -ForegroundColor Yellow }
    
        $errors | ForEach-Object {
            $errorMessage = "`n❌ Error Details:`n"
            $errorMessage += "   └─ Message: $($_.Message)`n"
            $errorMessage += "   └─ Location: Line $($_.LineNumber), Position $($_.LinePosition)`n"
            $errorMessage += "   └─ Path: $($_.Path)`n"
            $errorMessage += "   └─ Value: $($_.Value)"
            
            if ($_.ChildErrors) {
                $errorMessage += "`n   └─ Related Issues:"
                $_.ChildErrors | ForEach-Object {
                    $errorMessage += "`n      ↳ $($_.Message)"
                }
            }

            $userErrorMessages += $errorMessage

            if ($PrettyPrint) {
                Write-Host $errorMessage
            }
        }
    }

    $errorDetails = [System.Collections.Generic.List[PSCustomObject]]::new()
    $i = 0
    foreach ($error in $errors) {
        $errorDetails += [PSCustomObject]@{
            Message       = $error.Message
            UserMessage   = $userErrorMessages[$i]
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
        $i++
    }

    return [PSCustomObject]@{
        Valid  = $valid
        Errors = $errorDetails
    }
}
