param
(
[string] $Environment
)
function DeployFile([string] $File,[string] $DatabaseServer,[string] $Database,[string] $User,[string] $Password)
{
            Write-Output "Executing... $File on $DatabaseServer"
            sqlcmd -S $DatabaseServer -d $EnvironmentSettings.Database -i $File -U $User -P $Password | Tee-Object -Variable scriptOutput | Out-NULL
            if ($scriptOutput -ne ""){
                foreach ($line in $scriptOutput){Write-Host $line -ForegroundColor "Red"}
                $scriptOutput = ""
            }
}

function DeployFolder([string] $Folder,[string] $DefaultLocation,[string] $DatabaseServer,[string] $Database,[string] $User,[string] $Password)
{
   if (Test-Path $Location)
   {
        Write-Host "$Location execution will start in 5 seconds... on $DatabaseServer /n" -foregroundcolor "Blue"
        Start-Sleep -s 5
        Get-ChildItem $Location  -Filter *.sql | Foreach-Object {
            DeployFile -File $_.FullName -DatabaseServer $DatabaseServer -Database $Database -User $User -Password $Password
        }
        
        Write-Host $("`n" + $Location + ' execution complete...'+ "`n") -foregroundcolor "Green"
    }
    else
    {
        Write-Host ($Location + " does not exists. Skipping Folder...") -foregroundcolor "Red"
    }
}

function Deploy([object] $Folders,[string] $DefaultLocation,[string] $DatabaseServer,[string] $Database,[string] $User,[string] $Password)  
{

    $Folders|ForEach-Object{
        $Location = $($DefaultLocation + '\' + $_.Name)
        Write-Verbose "Executing Script for $Location..."
        DeployFolder -Location $Location -DefaultLocation $DefaultLocation -DatabaseServer $DatabaseServer -Database $Database -User $User -Password $Password
    }
}

[xml] $Settings = Get-Content ".\deployconfig.xml"

$Folder = $Settings.Settings.Folder
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

Write-Host $continue_flag $Folder $DefaultLocation $Settings.Settings.Environment.Server $EnvironmentSettings.Database $EnvironmentSettings.User $EnvironmentSettings.Password
Deploy -Folders $Folder -DefaultLocation $DefaultLocation -DatabaseServer $Settings.Settings.Environment.Server.ToString() -Database $EnvironmentSettings.Database.ToString() -User $EnvironmentSettings.User.ToString() -Password $EnvironmentSettings.Password.ToString()

Read-Host  "Deployment Complete. Please check errors reported above. Press any key to exit..."
