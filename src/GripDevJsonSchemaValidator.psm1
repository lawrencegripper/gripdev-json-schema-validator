function Test-JsonSchema {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SchemaPath,

        [Parameter(Mandatory = $true)]
        [string]$JsonPath
    )

    try {
        $schemaContent = Get-Content -Path $SchemaPath -Raw
        $jsonContent = Get-Content -Path $JsonPath -Raw

        $schema = [Newtonsoft.Json.Schema.JSchema]::Parse($schemaContent)
        $json = [Newtonsoft.Json.Linq.JToken]::Parse($jsonContent)

        $errors = New-Object 'System.Collections.Generic.List[Newtonsoft.Json.Schema.ValidationError]'
        $valid = $json.IsValid($schema, [ref]$errors)

        $errorDetails = @()
        foreach ($error in $errors) {
            $errorDetails += [PSCustomObject]@{
                Message      = $error.Message
                LineNumber   = $error.LineNumber
                LinePosition = $error.LinePosition
                Path         = $error.Path
            }
        }

        return $errorDetails
    }
    catch {
        Write-Error "Error: $_"
    }
}
