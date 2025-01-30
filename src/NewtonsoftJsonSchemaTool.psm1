function Test-JsonSchema {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Schema,

        [Parameter(Mandatory = $true)]
        [string]$Json
    )

    try {
        $schema = [Newtonsoft.Json.Schema.JSchema]::Parse($Schema)
        $json = [Newtonsoft.Json.Linq.JToken]::Parse($Json)

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
