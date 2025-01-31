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

    if ($PrettyPrint) {
        if ($valid) {
            Write-Host "✅ JSON is valid." -ForegroundColor Green
        }
        else {
            Write-Host "`n❌ JSON validation failed!" -ForegroundColor Red
            Write-Host "   Found the following errors:`n" -ForegroundColor Yellow
        
            $errors | ForEach-Object {
                Write-Host "   Error Details:" -ForegroundColor Magenta
                Write-Host "   └─ Message: $($_.Message)" -ForegroundColor White
                Write-Host "   └─ Location: Line $($_.LineNumber), Position $($_.LinePosition)" -ForegroundColor Gray
                Write-Host "   └─ Path: $($_.Path)" -ForegroundColor Gray
                Write-Host "   └─ Value: $($_.Value)" -ForegroundColor Gray
            
                if ($_.ChildErrors) {
                    Write-Host "   └─ Related Issues:" -ForegroundColor Yellow
                    $_.ChildErrors | ForEach-Object {
                        Write-Host "      ↳ $($_.Message)" -ForegroundColor DarkYellow
                    }
                }
                Write-Host ""
            }
        }
    }

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
