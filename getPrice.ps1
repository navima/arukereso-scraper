param (
    [parameter(ValueFromPipeline = $true)][string[]]$types = @()
)

#Requires -Version 7

# Install the module on demand
If (-not (Get-Module -ErrorAction Ignore -ListAvailable PowerHTML)) {
    Write-Verbose "Installing PowerHTML module for the current user..."
    Install-Module -Name PowerHTML -Scope CurrentUser -ErrorAction Stop
}
Import-Module -ErrorAction Stop PowerHTML

function Get-MinPrice {
    param (
        $typename
    )
    #$searchName = 'rtx-2060'
    $searchName = $typeName

    $url = "https://www.arukereso.hu/videokartya-c3142/$searchName/?orderby=1"
    Write-Information $url -InformationAction Continue
    
    $req = curl -L -s $url
    $htmlpath = "$searchName.html"
    $req > "$htmlpath"
    $html = ConvertFrom-Html -Path $htmlpath
    
    $searchClass = 'price'
    
    $objs = $html.selectnodes("//div[@class=""$searchclass""]")[0]
    
    $smallestStr = $objs[0].InnerText
    $smallestInt = [int32]($smallestStr.Replace(' ', '') -replace '[^0-9]*', '')
    
    Remove-Item -Path "$htmlpath"

    Return $smallestInt
}

function Get-MinPrices {
    param (
        $typeNames
    )

    $ress = @{}

    $typeNames | ForEach-Object {
        $res = Get-MinPrice($_)
        $ress.Add($_, $res)
    }

    Return $ress
}

$ret = Get-MinPrices($types)

$sorted = $ret.GetEnumerator() | Sort-Object -Property key

$csv = $sorted | Select-Object name, value | ConvertTo-Csv
$str = $sorted | Out-String

Write-Information $str -InformationAction Continue
Write-Output $csv