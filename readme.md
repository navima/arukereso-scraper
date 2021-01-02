# PPPS1

PowerShell scripts to scrape *certain* websites.

Also a summarizing Excel Worksheet

## Requirements:

### The scripts use

* curl
* PowerHTML

You will be prompted to install PowerHTML if it isn't detected

### Other

* The Excel Worksheet has PowerQuery queries to the filenames in the _[Example:](#example)_ section;  
The paths are dynamic, so the .xlsx, and .csv files need only be in the same folder.  
I don't know if other software support PowerQuery, so I assume this can only be worked with in MS Excel.

## Usage:

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

## Example:

### Refreshing prices

```powershell 
.\getTypes.ps1 'https://www.arukereso.hu' 'videokartya-c3142' 5 | .\getPrice.ps1 > prices.csv
```

### Refreshing benchmarks

```powershell
curl https://www.userbenchmark.com/resources/download/csv/GPU_UserBenchmarks.csv > .\GPU_UserBenchmarks.csv
```
