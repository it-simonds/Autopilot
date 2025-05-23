# Step 1: Ensure TLS 1.2 is used for secure communication
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Step 2: Create a directory to store the HWID CSV file
New-Item -Type Directory -Path "C:\HWID" -ErrorAction SilentlyContinue

# Step 3: Navigate to the folder
Set-Location -Path "C:\HWID"

# Step 4: Ensure the Path includes necessary directories (optional step based on your environment)
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"

# Step 5: Set Execution Policy to allow script execution in this session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned

# Step 6: Install the Get-WindowsAutopilotInfo script if it’s not already installed
Install-Script -Name Get-WindowsAutopilotInfo -Force

# Step 7: Retrieve the device's serial number
$serialNumber = (Get-WmiObject Win32_BIOS).SerialNumber

# Step 8: Generate the Autopilot HWID CSV file using Get-WindowsAutopilotInfo
$csvFilePath = "C:\HWID\$serialNumber.csv"
Get-WindowsAutopilotInfo -OutputFile $csvFilePath

Write-Host "Autopilot Hardware ID CSV generated at $csvFilePath"


# Step 8: Obfuscate GitHub Personal Access Token (PAT)

$part1 = "github_pat_11BLDQCUY0sN6XG3Wcgbfo_"  # First part of the PAT
$part2 = "hoKqBFW74oxIs90DQbuN8aAE2n6yd02XTwz0x"  # Middle part of the PAT
$part3 = "AKOZ1sTVLONPHTXC4evGAP" # Last part of the PAT

# Rejoin the token
$githubToken = $part1 + $part2 + $part3

# GitHub details
$githubUsername = "it-simonds"            # Replace with your GitHub username
$repository = "it-simonds/Autopilot"  # Replace with your GitHub repository
$branch = "main"                           # Replace with your target branch (usually 'main' or 'master')
$githubFilePath = "autopilot/$serialNumber.csv"  # Replace with the path where you want to upload the file in the repo

# Step 9: Read CSV file contents and encode it in base64 for the GitHub API
$fileContent = [IO.File]::ReadAllBytes($csvFilePath)
$fileContentBase64 = [Convert]::ToBase64String($fileContent)

# Step 10: Prepare the GitHub API URL
$uploadUrl = "https://api.github.com/repos/$repository/contents/$githubFilePath"

# Step 11: Prepare the body for the API call
$body = @{
    message = "Upload Autopilot HWID CSV file"
    content = $fileContentBase64
    branch  = $branch
} | ConvertTo-Json

# Step 12: Prepare Headers for the API call (Authorization and Content-Type)
$headers = @{
    "Authorization" = "Bearer $githubToken"
    "Content-Type"  = "application/json"
    "User-Agent"    = $githubUsername
}

# Step 13: Upload the CSV file to GitHub
$response = Invoke-RestMethod -Uri $uploadUrl -Method Put -Headers $headers -Body $body

# Step 14: Output success message
Write-Host "Autopilot CSV uploaded to GitHub repository successfully."