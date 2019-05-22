if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function get-latestmiiShop ([String] $question,[String] $installType)
{
    Write-Output $question
    # Download Engarak/MiiShop release from github
    $repo = 'Engarak/MiiShop'
    If ($installType.ToUpper() -eq 'UPGRADE')
    {
        $file = 'miiShop_upgrade-0_2_x-0_2_7.zip'
        $uoriDir = Get-Folder -displayMesage $question
    }
    Else
    {
        $file = 'miiShop_install-0_2_7.zip'
        $uoriDir = Get-Folder -displayMesage $question
    }

    $releases = "https://api.github.com/repos/$repo/releases"

    Write-Output 'Determining latest release'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $tag = (Invoke-WebRequest -Uri $releases -UseBasicParsing | ConvertFrom-Json)[0].tag_name

    $download = "https://github.com/$repo/releases/download/$tag/$file"
    $name = $file.Split(".")[0]
    $zip = "$name-$tag.zip"

    Write-Output 'Dowloading latest release'

    Invoke-WebRequest $download -Out $zip

    Write-Output 'Upgrading/Installing...'
    Expand-Archive -path $zip -DestinationPath $uoriDir -Force 

    # Cleaning up target dir
    Remove-Item $name -Recurse -Force -ErrorAction SilentlyContinue

    # Removing temp files
    Remove-Item $zip -Force

    #$file = Get-ChildItem "$uoriDir\database\settings.csv" #for future upgrades force the settings file to get updated to force a rebuild
    #$file.LastWriteTime = Get-Date
    Write-Output 'Upgrade/Install completed, launching miiShop'
    $filePath = "$uoriDir\start.bat"

    Stop-Transcript

    Invoke-Expression $filePath
}

Function Get-Folder ([string]$displayMesage)
{
    Add-Type -AssemblyName System.Windows.Forms | Out-Null

    $initialDirectory = $env:HOMEDRIVE
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = $displayMesage
    $foldername.rootfolder = 'MyComputer'

    $ButtonType = [System.Windows.Forms.MessageBoxButtons]::RetryCancel
    $MessageIcon = [System.Windows.Forms.MessageBoxIcon]::Error
    $MessageBody = 'You must select a folder'
    $MessageTitle = 'Error'
    
    Do
    {
        If($foldername.ShowDialog() -eq 'OK')
        {
            return $foldername.SelectedPath
        }
        Else
        {
            $result = [System.Windows.Forms.MessageBox]::Show($MessageBody, $MessageTitle, $ButtonType, $MessageIcon)
            
            If ($result -eq 'Cancel')
            {
                Exit 1
            }
        }
    } While ($true)
}

#get a start date, formatted for files
$dateFormat = 'M-d-y-hh_mm_ss'
$date = (get-date).ToString($dateFormat)

#Start Transcript logging for what the window says
Start-Transcript -Path ('{0}\logs\MiiShopInstall_{1}.log' -f $PSScriptRoot, $date)

$title = 'Install or Upgrade'
$message = 'Is this an Install or Upgrade?'

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Upgrade", 'Upgrade'
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&Install", 'Install'

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
# SIG # Begin signature block
# MIIFYQYJKoZIhvcNAQcCoIIFUjCCBU4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQURzw2TE2+YBmXy4IbGGIkBrua
# lt+gggMGMIIDAjCCAeqgAwIBAgIQXvibBfOpFbJJxUJ9WcAiEDANBgkqhkiG9w0B
# AQsFADAQMQ4wDAYDVQQDDAVUSVRBTjAeFw0xOTA0MjAwNDAyMzNaFw0yMDA0MjAw
# NDIyMzNaMBAxDjAMBgNVBAMMBVRJVEFOMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
# MIIBCgKCAQEAsJolne0jdB/Rt4/hG0HPh7wbI4RRKdB7T3jsNFjyRD/9pre1OP+w
# JbhsBEnfcQOOu2AGJPO8prqgA+JgCIdw/2CM2NhLQ/dmtMDwRkLCnzdrLd42Yj/U
# rPArWBqpJy+4EAw6ueGUBzuSSzPgqWM9fDCIvxCqAGMIEQHDCM3E268ngUl/KOai
# UgQ7vjOWeI8G3Akyj4mnCYBjF5Y/W8D7dlgPGrRhFfxxXBL2ky/3R+42sQl7UH8s
# EXOeEGHI3pYYkIm42EnDOuNx1F03x9CA6uHMo3y7lKAF3QmM/VIWg7kUdPnN8lWL
# 4OfeKaPj3kNq7AHk+J2sBGa5ktbXSG/OTQIDAQABo1gwVjAOBgNVHQ8BAf8EBAMC
# B4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEAYDVR0RBAkwB4IFVElUQU4wHQYDVR0O
# BBYEFCXPxQZnoT5Wu2iA/s9nMzhBeowMMA0GCSqGSIb3DQEBCwUAA4IBAQA7l9cT
# mtLhRHqL9ahxLZEyQQcPyfkC9xC5/RdNpaJM/w0nT4KA2OJmOovl1+5aCcs3hO/l
# eAfNmpLoTF6MShCnCKQRsytlJqgFTyI7lTZp3pWowMaPuodN3jI3UdtvMR4O0tIm
# yyuvKxHcFD+U5/E20zHZIu4M6hwqMeiAGR8+LOHykGAOGTr1e7VpOW703YF9ht70
# jTtbgbLl4iiMWXLRZScrhoj/j3nKjGoV/9/m72LEhqTKc9EPraLqYLloZfP148xO
# x3iTerLtGa0EIG6eqYKggdFMbx0NxZazavQZwk36l4jrN5TBS5fngfO3H7koosHz
# YnDb+gghURXKswI+MYIBxTCCAcECAQEwJDAQMQ4wDAYDVQQDDAVUSVRBTgIQXvib
# BfOpFbJJxUJ9WcAiEDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAA
# oQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4w
# DAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUYw7z9wawDhiH73DpGyFgATw0
# DL0wDQYJKoZIhvcNAQEBBQAEggEAqfMBHrUeUcMd1OeX9WoIdQUMhgppa+yHZP6x
# Zz3rwLIBEyAmi6CWU9KdeTl+GU7AWpOnX+ElMcOqwZaGnKnnUd6N0Kotfv/j2Ols
# a5qjed4CxJLv4TOJQVzEzErEiN+reiKbgtuusWGW41nxc2jOuAxHo2mTlMZml+SS
# 6Qdz8x4A7o87Aw9BzXAhM3sQzx1AHZsm0RU4klCdxrApuYvvnfim7KGG+V24eaTI
# vrR8MZuLpQjcrcDHVZnxR0gAEP+8q25fUFgvX3CU/KMDSD4xTujzspe8Tk9lCB0b
# wysvYgYO3RQLMjf5Gxv/JKj+tRdN9P+8M/rIjDR23W0LsS73Xg==
# SIG # End signature block
