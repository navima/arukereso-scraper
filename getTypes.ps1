param (
    [string] $searchUrl = 'https://www.arukereso.hu',
    [string] $searchClass = 'videokartya-c3142',
    [int] $returnIndex = -1
)

#Requires -Version 7

# Install the module on demand
If (-not (Get-Module -ErrorAction Ignore -ListAvailable PowerHTML)) {
    If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Information "Run this script in Admin, or install PowerHTML in an Admin prompt." -InformationAction Continue
        Write-Information "Install-Module PowerHTML -ErrorAction Stop" -InformationAction Continue
        Break
    }
    Write-Verbose "Installing PowerHTML module for the current user..."
    Install-Module PowerHTML -ErrorAction Stop
}
Import-Module -ErrorAction Stop PowerHTML


$url = "$searchUrl/$searchClass"
$req = curl -L -s $url
$htmlpath = "$searchClass.html"
$req > "$htmlpath"

$html = ConvertFrom-Html -Path $htmlpath

[string[]]$strs = @()

$html.SelectNodes('//div[contains(@class, ''property-box'')]') | ForEach-Object -Begin {
    $i = 0 
} -Process {
    if ($returnIndex -eq -1 -or $i -eq $returnIndex) {
        $_.SelectNodes('.//li[@data-akvalue]') | ForEach-Object {
            if ($_) {
                $t = $_.GetAttributeValue('data-akvalue', '')
                Write-Information $t
                $strs += $t
            }
        }    
    }
    $i++
} -End $null

Write-Output (, $strs)
