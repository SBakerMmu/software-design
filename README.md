# Writeside build & run

This project builds a Writerside-generated textbook


and mounts it into an Apache HTTP Server image

## Prerequisites
- Docker Desktop running and available in your PATH (`docker --version` works)

## Files
- `build.ps1` — rebuilds the Writerside output, unzips it into `website/`, builds the Docker image, and restarts a named container.

## To build and run the site with the script
Because of the use of  relative paths must run the script the repo root
```powershell
./build.ps1
```

If script execution is blocked, use a one-time bypass for that PowerShell session:
```powershell
powershell -ExecutionPolicy Bypass -Command "Set-Location D:\scratch\Sample; ./build.ps1"
```
