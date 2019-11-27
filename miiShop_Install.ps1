if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function get-latestmiiShop ([String] $question,[String] $installType)
{
    Write-Output $question
    # Download Engarak/MiiShop release from github
    $repo = "Engarak/MiiShop"
    if($installType.ToUpper() -eq 'UPGRADE')
    {        
        $file = "miiShop_upgrade-0_2_x-0_2_9.zip"        
        $uoriDir = Get-Folder -displayMesage 'Where are the .cia files located?'
    }
    else
    {
        $file = "miiShop_install-0_2_9.zip"
        $uoriDir = Get-Folder -displayMesage 'Where is the miiShop.ps1 file located?'
    }

    $releases = "https://api.github.com/repos/$repo/releases"

    Write-Output 'Determining latest release'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $tag = (Invoke-WebRequest -Uri $releases -UseBasicParsing | ConvertFrom-Json)[0].tag_name

    $download = "https://github.com/$repo/releases/download/$tag/$file"
    $name = $file.Split(".")[0]
    $zip = "$name-$tag.zip"

    Write-Output 'Dowloading latest release'

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest $download -Out $zip

    Write-Output 'Extracting release files'
    Expand-Archive -path $zip -DestinationPath $uoriDir -Force 

    # Cleaning up target dir
    Remove-Item $name -Recurse -Force -ErrorAction SilentlyContinue 

    # Moving from temp dir to target dir
    Write-Output 'Upgrading/installing...'
    $folder = $zip.Replace('.zip','')
    Get-ChildItem -Path $folder -Recurse |  Move-Item -Destination $uoriDir -Force

    # Removing temp files
    Remove-Item $zip -Force
    Remove-Item $folder -Recurse -Force
    $filePath="$uoriDir\start.bat" 
    set-location $uoriDir
    #$file = Get-ChildItem "$uoriDir\database\settings.csv" #for future upgrades force the settings file to get updated to force a rebuild
    #$file.LastWriteTime = Get-Date
    Write-Output 'Upgrade/install completed, launching miiShop'
    Stop-Transcript
    Invoke-Expression $filePath
}

Function Get-Folder ([string]$displayMesage)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = $displayMesage
    $foldername.rootfolder = "MyComputer"

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

#get a start date, formatted for files
$dateFormat = 'M-d-y-hh_mm_ss'
$date=(get-date).ToString($dateFormat)

#Start Transcript logging for what the window says
Start-Transcript -Path ('{0}\logs\MiiShopInstall_{1}.log' -f $PSScriptRoot, $date) 

$title = "Install or Upgrade"
$message = "Is this an Install or Upgrade?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Upgrade", "Upgrade"
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&Install", "Install"

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $Options, 0)

Switch ($result)
     {
          0 { 
                get-latestmiiShop -question 'Where is the miiShop.ps1 file located?'
           }
          1 { 
                get-latestmiiShop -question 'Where are your 3DS games (.cia files) located?'
           }

     }

Stop-Transcript