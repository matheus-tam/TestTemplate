function GetIdeaPhase() {
    # Read the project.json file
    $currentDirectory = $PSScriptRoot
    $projectJsonPath = Join-Path -Path $currentDirectory -ChildPath "project.json"
    $projectJson = Get-Content -Path $projectJsonPath | ConvertFrom-Json
    
    # Extract the automationHubIdeaUrl value
    $automationHubIdeaUrl = $projectJson.automationHubIdeaUrl
    
    
    # Parse the string after the last "/"
    $ideaName = $automationHubIdeaUrl.Split("/")[-1]
    $searchQuery = $ideaName -replace '-', ' '
    
    
    # Define auth token for API calls
    $token = "40fb6963-a66a-4cb4-86b3-868bc22138c3/973805d9-ae37-4e3b-9fe2-b4cbdd706e26"
    
    # GET request to /automations endpoint
    $automationsUrl = "https://staging-automation-hub.uipath.com/api/v1/openapi/automations?s=$searchQuery"
    $headers = @{
        "Authorization" = "Bearer $token"
        "x-ah-openapi-auth" = "openapi-token"
        "Content-Type" = "application/json"
    }
    
    $responseContent = Invoke-RestMethod -Uri $automationsUrl -Method Get -Headers $headers
    
    # Output the results
    Write-Output "Idea name:" $ideaName
    
    # Parse the API response
    
    if ($responseContent.statusCode -eq 200 -and $responseContent.message -eq "Success") {
        $processes = $responseContent.data.processes
        $matchingProcess = $processes | Where-Object { $_.process_slug -eq $ideaName }
    
        if ($matchingProcess) {
            $processPhaseId = $matchingProcess.process_phase_id
            Write-Output "Matching process found. Process Phase ID: $processPhaseId"
        } else {
            Write-Output "No matching process found for idea: $ideaName"
        }
    } else {
        Write-Output "API request failed. Status Code: $($responseContent.statusCode), Message: $($responseContent.message)"
    }
    
    #Check the idea phase
    
    if ($processPhaseId -ge 7) {
                $processPhaseIdStatus= "Process phase ID is passed the development phase in Automation Hub. All good!"
            } else {
                $processPhaseIdStatus= "WARNING: Process phase in Automation Hub is not at least Testing"
            }
        Write-Output $processPhaseIdStatus    
        return $processPhaseIdStatus
}
