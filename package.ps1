$ErrorActionPreference = "Stop"

Write-Host "Building project..."
cd backend\practice
.\gradlew build -x test

Write-Host "Packaging with jpackage..."
$javaBin = "$env:JAVA_HOME\bin"
if (!(Test-Path "$javaBin\jpackage.exe")) {
    Write-Error "jpackage not found at $javaBin\jpackage.exe"
}

$jarFile = "practice-0.0.1-SNAPSHOT.jar"
$inputDir = "build\jpackage_input"

if (Test-Path $inputDir) {
    Remove-Item -Recurse -Force $inputDir
}
New-Item -ItemType Directory -Force -Path $inputDir
Copy-Item "build\libs\$jarFile" -Destination $inputDir

if (Test-Path "build\jpackage") {
    Remove-Item -Recurse -Force "build\jpackage"
}

& "$javaBin\jpackage.exe" --type app-image --name ToeicApp --input $inputDir --main-jar $jarFile --dest build\jpackage --win-console

if ($LASTEXITCODE -ne 0) {
    Write-Error "jpackage failed"
}

Write-Host "Copying media data into the app bundle..."
if (Test-Path "..\..\data") {
    Copy-Item -Path "..\..\data" -Destination "build\jpackage\ToeicApp\data" -Recurse -Force
}

Write-Host "Packaging complete! Executable is at backend\practice\build\jpackage\ToeicApp"
