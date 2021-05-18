import-module au

Get-Item *.nupkg | Remove-Item

function global:Get-GithubRepoInfo {
    Param (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $User,
         [Parameter(Mandatory=$true, Position=1)]
         [string] $Repository
    )

    $global:releases = "https://api.github.com/repos/$User/$Repository/releases/latest"
    $global:download_page = Invoke-WebRequest $releases | ConvertFrom-Json
    $global:tag = $download_page.tag_name
    $global:links = $download_page.assets
}

function global:Get-ExeFileVersion {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$URL
    )

    $TempFile = [System.IO.Path]::GetTempFileName()
    Invoke-WebRequest -Uri "$url" -Outfile "$TempFile"

    # Windows can do this
    if ($IsWindows) {
        $global:version = ([System.Diagnostics.FileVersionInfo]::GetVersionInfo("$TempFile").FileVersion).Trim()
    }

    # Let's use exiftool here
    if ($IsLinux) {
        $exiftool = "$(Get-Command 'exiftool')"
        if ($exiftool) {
            $global:version = (exiftool -s -s -s -ProductVersionNumber "$TempFile").Trim()
        }
    }
    
    Remove-Item "$TempFile" -Force
}