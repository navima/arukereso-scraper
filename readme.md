# Árukereső Scraper

PowerShell scripts to scrape [arukereso.hu](https://arukereso.hu) for GPU prices.

Extra scripts to send notification emails to addresses based on a watchlist.

Github Actions configurations that run these scripts correctly and generate HTMLs.

A dynamic excel worksheet that summarizes scraped data and calculates various things.

## Requirements

### The scripts use

* curl
* PowerHTML

You will be prompted to install PowerHTML if it isn't detected

### Other

* The Excel Worksheet has PowerQuery queries to the filenames in the _[Example](#example)_ section;  
The paths are relative, so the .xlsx, and .csv files need only be in the same folder.  

## Usage

### GetTypes

```powershell
.\getTypes.ps1
    [[-searchUrl] <string>]
    [[-searchClass] <string>]
    [[-returnIndex] <int>]
```

Returns: `string[]`

### GetPrice

```powershell 
.\getPrice.ps1 [[-types] <string[]> (pipable)]
```

Returns: `string[]` (CSV)

## Example

### Refreshing prices

```powershell 
.\getTypes.ps1 'https://www.arukereso.hu' 'videokartya-c3142' 5 | .\getPrice.ps1 > prices.csv
```

### Refreshing benchmarks

```powershell
curl https://www.userbenchmark.com/resources/download/csv/GPU_UserBenchmarks.csv > .\GPU_UserBenchmarks.csv
```

### Refreshing the worksheet

(On the ribbon)  
Data > Refresh All
