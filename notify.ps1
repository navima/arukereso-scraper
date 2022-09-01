param (
    [string]$MAILGUN_API_KEY = '',
    [string]$WATCHLIST_SOURCE = '',
    $csv_file = '',
    [boolean]$send_email = $true
)

Write-Output "Filename: $csv_file"

$csv = Import-Csv $csv_file
$prices = @{}
$csv | ForEach-Object {
    $prices.Add($_.Name, $_.Value)
}

Write-Output ("Rows: " + $prices.Count)

$watcherListJson = curl -s $WATCHLIST_SOURCE
$watcherlist = $watcherListJson | ConvertFrom-Json 

Write-Output ("Watchlist length: " + $watcherlist.count)

$watcherlist | Where-Object {
    return $_.enabled
} | ForEach-Object {
    [string]$watcher_addr = $_.address
    $watchlist = $_.watchlist

    Write-Output ("Processing " + -join $watcher_addr[0..4] + "...")

    $text

    $watchlist | ForEach-Object {
        $Name = $_.product
        [int]$Value = $_.price

        [int]$actualprice = $prices[$Name]
        if ($prices.ContainsKey($Name) -and $actualprice -lt $Value -and $actualprice -ne 0) {
            $text += "$Name for $actualprice (<$Value) https://www.arukereso.hu/videokartya-c3142/$Name/?orderby=1
"
        }
    }

    if (-not $text -eq '') {
        Write-Output "Sending: "
        Write-Output $text
        if ($send_email) {
            curl -s --user "api:$MAILGUN_API_KEY" https://api.eu.mailgun.net/v3/vikt0r.eu/messages -F from='Scraper <Scraper@vikt0r.eu>' -F to="$watcher_addr" -F subject='Watch notification' -F text="$text"
        }
    }
}
