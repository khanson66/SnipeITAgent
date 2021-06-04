Import-Module -Name "SnipeITPS"

#loading configuration file
$config = Get-Content -Path "./config.json" | ConvertFrom-Json

#load functions
foreach($p in Get-ChildItem -Path ".\Functions"){
    . $p.FullName
}

Set-SnipeItInfo -url $config.url -apiKey $config.api_key

# Check to see if asset exist in database and meets conditions for upload if not exit
$asset = Get-SnipeItAsset -asset_serial (Get-SerialNumber)
$fieldset = (Get-SnipeItFieldset -id $config.target_fieldset_id)

if ($null -eq $asset){
    Write-Host -Message "[!] Asset Does Not Exist in the Database" -ForegroundColor Red
    exit(1)
}elseif( ($fieldset.models.rows.id -notcontains $asset.model.id)){
    Write-Host -Message "[!] Asset Is Not Compatible With The Auto Entry" -ForegroundColor Red
    exit(2)
}

$custom = @{}

foreach($field in $config.custom_fields.GetEnumerator()){
    write-host ($fieldset.fields.rows | Where-Object -FilterScript {$_.name -eq $field.dbname}).db_column_name
    $custom.Add(($fieldset.fields.rows | Where-Object -FilterScript {$_.name -eq $field.dbname}).db_column_name, (& $field.function))
}

Set-SnipeItAsset -id $asset.id -name $env:COMPUTERNAME -customfields $custom
