# Name of build output directory
$output = 'output'
# Name of directory containing generated PDF
$pdf = "pdf"
# Path within the container for site sources.
$writersideBuilderSources = "/opt/sources"
# Path within the container for pdf build output.
$writersideBuilderPdfOutput = "/opt/sources/$pdf"
# Writerside Module (directory) and instance to build, separated by a slash /
$moduleInstance ='src/sda'
# Writerside instance ID as Uppercase
$instanceId ='SDA'
# See https://www.jetbrains.com.cn/en-us/help/writerside/build-with-docker.html#builder-image-with-the-generated-website
$runner = 'other'
# The name of the PDF configuration file to be generated. The file must be located in the cfg directory of the module
$pdfConfig = "PDF.xml"
# Final name for the PDF file
$pdfName = "software-design.pdf"


$outputPath = Join-Path -Path "." -ChildPath $output
if (Test-Path $outputPath) {
    Remove-Item $outputPath -Recurse -Force
}

$pdfPath = Join-Path -Path "." -ChildPath $pdf
if (Test-Path $pdfPath) {
    Remove-Item $pdfPath -Recurse -Force
}


# Build a PDF using the Writerside Builder Docker image
# the $dpfConfig file must be located int he ./cfg directory of the project root
docker run --rm --mount "type=bind,source=.,target=$writersideBuilderSources" -e "SOURCE_DIR=$writersideBuilderSources" -e "MODULE_INSTANCE=$moduleInstance" -e "OUTPUT_DIR=$writersideBuilderPdfOutput" -e "RUNNER=$runner" -e "PDF=$pdfConfig" jetbrains/writerside-builder:latest

$pdfFile = Join-Path -Path $pdfPath -ChildPath "pdfSource$($instanceId).pdf"
Rename-Item -Path $pdfFile -NewName $pdfName
$pdfFile = Join-Path -Path $pdfPath -ChildPath $pdfName
Write-Host "PDF File: $pdfFile"

