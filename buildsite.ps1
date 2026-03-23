# Name of build output directory
$output = 'output'
# Name of directory containing unzipped website
$website = 'website'
# Path within the container for site sources.
$writersideBuilderSources = "/opt/sources"
# Path within the container for website build output.
$writersideBuilderWebOutput = "/opt/sources/$output"
# Writerside Module (directory) and instance to build, separated by a slash /
$moduleInstance ='src/sda'
# Writerside instance ID as Uppercase
$instanceId ='SDA'
# See https://www.jetbrains.com.cn/en-us/help/writerside/build-with-docker.html#builder-image-with-the-generated-website
$runner = 'github'

# Name for the Docker container to run the website. Container name must be lowercase
$containerName='software-design-website-container'
# Host Port for the website.
$hostPort=8080

$outputPath = Join-Path -Path "." -ChildPath $output
if (Test-Path $outputPath) {
    Remove-Item $outputPath -Recurse -Force
}

$websitePath = Join-Path -Path "." -ChildPath $website
if (Test-Path $websitePath) {
    Remove-Item $websitePath -Recurse -Force
}

# Build a website using the Writerside Builder Docker image
# --rm to automatically remove the container filesystem when the process exits. No stopped container is left behind after the  build completes.
# --mount "type=bind,source=.,target=$writersideBuilderSources" creates a bind mount:
# type=bind — bind-mounts a host path into the container.
# source=. uses current host directory (where the command is run) as the source. This must be the project root location
# target=$writersideBuilderSources — inside the container, the mount is available at the path stored in $writersideBuilderSources
docker run --rm --mount "type=bind,source=.,target=$writersideBuilderSources" -e "SOURCE_DIR=$writersideBuilderSources" -e "MODULE_INSTANCE=$moduleInstance" -e "OUTPUT_DIR=$writersideBuilderWebOutput" -e "RUNNER=$runner" jetbrains/writerside-builder:latest

# Unzip the generated  website
$zipFile = "webHelp$($instanceId.ToUpper())2-all.zip"
Expand-Archive -Path (Join-Path -Path $outputPath -ChildPath $zipFile) -DestinationPath $websitePath -Force

# Force stop and remove any existing named container
docker rm -f "$containerName"

# Run an instance of `httpd:latest` (the official Apache HTTP Server that tracks the newest stable release) in detached mode (-d), interactive mode (-i), and allocate a pseudo-TTY (-t).
# The container is named so can be removed in the previous step
# Mount the prebuilt website from `website/` into `/usr/local/apache2/htdocs/` in read-only mode.
# Map port on the host to port 80 in the container.
docker run -dit --mount "type=bind,source=$websitePath,target=/usr/local/apache2/htdocs/,readonly" --name "$containerName" -p "$($hostPort):80" httpd:latest

Write-Host "To run the website, open a browser and navigate to http://localhost:$($hostPort)"
Write-Host "To stop the container: docker stop $containerName"
Write-Host "To remove the container: docker rm -f $containerName"

