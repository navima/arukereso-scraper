param (
    [int]$ref = -1
)

Import-Module -ErrorAction Stop PowerHTML

$searchClass = 'videokartya-c3142'
$url = "https://www.arukereso.hu/$searchClass"
$req = curl -L -s $url
$htmlpath = "$searchClass.html"
$req > "$htmlpath"

$html = ConvertFrom-Html -Path $htmlpath

[string[]]$strs = @()

$html.SelectNodes('//div[contains(@class, ''property-box'')]') | ForEach-Object -Begin {
    $i = 0 
} -Process {
    if ($ref -eq -1 -or $i -eq $ref) {
        $_.SelectNodes('.//li[@data-akvalue]') | % {
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
