# Define variables
$TomcatVersion = "9.0.54"  # Change this to the desired Tomcat version
$DownloadUrl = "https://archive.apache.org/dist/tomcat/tomcat-9/v$TomcatVersion/bin/apache-tomcat-$TomcatVersion-windows-x64.zip"
$TomcatInstallDir = "C:\Tomcat"

# Create a directory for Tomcat
New-Item -ItemType Directory -Force -Path $TomcatInstallDir

# Download Tomcat zip file
Invoke-WebRequest -Uri $DownloadUrl -OutFile "$env:TEMP\tomcat.zip"

# Extract the zip file
Write-Host "Extracting Tomcat..."
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$env:TEMP\tomcat.zip", $TomcatInstallDir)

# Remove the downloaded zip file
Remove-Item "$env:TEMP\tomcat.zip" -Force

# Set environment variables
[Environment]::SetEnvironmentVariable("CATALINA_HOME", $TomcatInstallDir, [EnvironmentVariableTarget]::Machine)

# Add Tomcat bin directory to the system PATH
[Environment]::SetEnvironmentVariable("PATH", "$($env:PATH);$TomcatInstallDir\bin", [EnvironmentVariableTarget]::Machine)

Write-Host "Tomcat $TomcatVersion has been installed to $TomcatInstallDir"
Write-Host "Please start Tomcat using $TomcatInstallDir\bin\startup.bat"
