# Software Design and Architecture Textbook

This project builds a JetBrains Writerside authored textbook locally to a website, and the project contains a Github action workflow that will deploy the locally built website to GitHub Pages.

The Github action is triggered by pushes to the `main` branch. It is therefore recommended that any development takes place on a local branch and built and tested locally before merging to `main` and pushing.

The `buildsite.ps1` script is used to build the website locally using a Writerside builder docker image. The local website is served using another Docker container running a standard Apache web server.

The `buildpdf.ps1` script is used to build  a PDF  locally using the same Writerside builder docker image. The .gitignore file is configured to ignore the generated PDF.

## Prerequisites
- PowerShell 7 or later to run the .ps1 scripts (`pwsh -v` works).
- Docker Desktop running and available in your PATH (`docker --version` works).

