param(
    [parameter(ValueFromPipeline = $true)][string[]]$types = @()
)

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

    $typeNames | % {
        $res = Get-MinPrice($_)
        $ress.Add($_, $res)
    }

    Return $ress
}

$types > dsa.txt
$ret = Get-MinPrices($types)
[string[]] $retstr = ($ret | Out-String -Stream) -ne '' | select -Skip 2
Write-Output $retstr
Write-Information $ret -InformationAction Continue