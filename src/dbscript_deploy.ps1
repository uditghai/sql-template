param
(
[string] $Environment
)

[xml] $Settings = Get-Content ".\ServerCredentials.xml"
$EnvironmentSettings = $Settings.Settings.Environment | Where-Object { $_.Name -eq $Environment }
#Get and Set Default Location for Procedures and Function
$DefaultLocation = $Settings.Settings.Defaults.Location.ToString()

Write-Host $('Source Location : '+$DefaultLocation)  -foregroundcolor "Red"

if ($EnvironmentSettings -eq $null){
    Write-Host $('There are no details available for the specified Envionment. Configuration details are available for the following environments:')
    Write-Output $Settings.Settings.Environment | Format-Table -Property Name
    $Invalid_Environment = 1
    while ($Invalid_Environment)
    {
        $Environment = Read-Host  "Enter a Valid Environment Name: "
        $EnvironmentSettings = $Settings.Settings.Environment | Where-Object { $_.Name -eq $Environment }
        if ($EnvironmentSettings -ne $null){
            $Invalid_Environment = 0
        }
    }
}

Write-Host $('Environment Execution Details:')
Write-Output $EnvironmentSettings | Format-Table -Property Name,Server,Database,User,Password -AutoSize -Wrap

$continue_flag = Read-Host  "Press (y) to Continue..."

if ($continue_flag -ne "y"){
    Write-Host "Terminating Deployment..." -ForegroundColor "Red"
    Start-Sleep -s 1
    exit
}

#For Each Folder (Functions / Procedures)
$Settings.Settings.Folder | ForEach-Object {
    $Location = $($DefaultLocation + '\' + $_.Name)
    if (Test-Path $Location)
    {
        Write-Host $($Location + ' execution will start in 5 seconds...' + "`n") -foregroundcolor "Blue"
        Start-Sleep -s 5
        Get-ChildItem $Location  -Filter *.sql | Foreach-Object {
            Write-Output ('Executing... ' + $_.FullName)
            & sqlcmd -S $EnvironmentSettings.Server -d $EnvironmentSettings.Database -i $_.FullName -U $EnvironmentSettings.User -P $EnvironmentSettings.Password | Tee-Object -Variable scriptOutput | Out-NULL
            if ($scriptOutput -ne ""){
                foreach ($line in $scriptOutput){Write-Host $line -ForegroundColor "Red"}
                $scriptOutput = ""
            }
        }
        
        Write-Host $("`n" + $Location + ' execution complete...'+ "`n") -foregroundcolor "Green"
    }
    else
    {
        Write-Host ($Location + " does not exists. Skipping Folder...") -foregroundcolor "Red"
    }

}

Read-Host  "Deployment Complete. Please check errors reported above. Press any key to exit..."
