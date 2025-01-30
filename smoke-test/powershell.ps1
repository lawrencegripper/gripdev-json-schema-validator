$ErrorActionPreference = "Stop"

function Run-Test {
    param (
        [string]$TestDir
    )

    $schemaFile = Join-Path $TestDir "schema.json"
    $jsonFile = Join-Path $TestDir "data.json"
    $expectedOutcomeFile = Join-Path $TestDir "expected-outcome.json"

    Write-Host "Running test in directory: $TestDir"
    Write-Host "Schema file: $schemaFile"
    Write-Host "JSON file: $jsonFile"
    Write-Host "Expected outcome file: $expectedOutcomeFile"

    # Read expected outcome
    $expectedOutcome = Get-Content -Raw -Path $expectedOutcomeFile | ConvertFrom-Json
    $shouldPass = $expectedOutcome.shouldPass
    $expectedError = $expectedOutcome.expectedError

    Write-Host "Expected outcome: $expectedOutcome"
    Write-Host "Should pass: $shouldPass"


    # Run the PowerShell module function
    Write-Host "Running PowerShell module with JSON file: $jsonFile..."
    $result = Test-JsonSchema -SchemaPath $schemaFile -JsonPath $jsonFile

    if ($result.Valid -eq $shouldPass) {
        if (-not $shouldPass -and $expectedError) {
            $errorFound = $false
            foreach ($error in $result.Errors) {
                if ($error.Message -like "*$expectedError*") {
                    $errorFound = $true
                    break
                }
            }
            if ($errorFound) {
                Write-Host "Test passed."
            } else {
                Write-Host "Test failed. Expected error message not found."
                exit 1
            }
        } else {
            Write-Host "Test passed."
        }
    } else {
        Write-Host "Test failed. Expected valid: $shouldPass"
        exit 1
    }
}

Set-Location $PSScriptRoot
Set-Location ..

# Import the module from the local directory`
Import-Module (Join-Path $PSScriptRoot "../pwsh-module/GripDevJsonSchemaValidator.psd1")

# Run all tests by walking the smoke-test directory
$testDirs = Get-ChildItem -Directory -Path "smoke-test"
foreach ($testDir in $testDirs) {
    Run-Test -TestDir $testDir.FullName
}

Write-Host "All smoke tests passed."
