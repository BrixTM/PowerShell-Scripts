function New-Shortcut
{ <# 
.SYNOPSIS
Creates a shortcut on the desktop, specifically made for use with intunewim do deploy through intune win32 app.

.PARAMETER Name
The name of the shortcut to appear on the desktop. 

.PARAMETER Desktop
Specify either "PublicDesktop", "CurrentUsersDesktop", "StartMenu" or "SystemStartMenu" to create the shortcut on the public desktop, the current user's desktop,
the Current Users Start Menu, or the System Start Menu. note that in order to install to the System Start Menu you need to run this as System/Admin. All other
options work as current user

.PARAMETER Path
The path to the file or URL to create the shortcut for. 

.PARAMETER Icon
Accepts "DefaultBrowser", "File", "Folder", "Drive", or "Chart". If "DefaultBrowser" is specified, the default browser's icon will be used. If no icon is specified, 
the default icon for the file type will be used. 

.PARAMETER IconPath
if ico is selected in $Icon this will be used to set the icon, in order for this to work it it needs to be set as .\filename and PS needs to be in the directory of the file, 
this is so that when using intunewim packages it works deploying through intune. If anything other than ico is selected this will do nothing and can be filled with dummy data

.EXAMPLE 
New-DesktopShortcut -Name Test -Path "c:\Temp" -Desktop CurrentUsersDesktop -Icon ico -Iconpath '.\test.ico'
Creates a shortcut on the users desktop named "Test" that points to c:\Temp\test with the icon as icon.ico #>

#Setting Paramaters for function arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String]$Path,
    [Parameter(Mandatory)]
    [String]$Name,
    [Parameter(Mandatory)]
    [validateset('PublicDesktop','CurrentUsersDesktop','StartMenu','SystemStartMenu')]
    [String]$Desktop,
    [Parameter(Mandatory)]
    [validateset('DefaultBrowser','File','Folder','Drive','Chart','ico')]
    [String]$Icon,
    [Parameter(Mandatory)]
    [String]$Iconpath

)
$shell = New-Object -ComObject WScript.Shell

#sets the location of the shortcut
switch ($Desktop) {
    'PublicDesktop' { $DesktopPath = $shell.SpecialFolders('AllUsersDesktop') }
    'CurrentUsersDesktop' { $DesktopPath = $shell.SpecialFolders('Desktop') }
    'StartMenu' {$DesktopPath = $shell.SpecialFolders('StartMenu')}
    'SystemStartMenu' {$DesktopPath = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs'}
}
#Sets varialbes for icon path, these will only be creates if ico is slected. These can be modified as required except for $shortcut
switch ($Desktop) {
    SystemStartMenu {  
    $IconFolder = "C:\Users\Default\AppData\Local\EUC\Icons"
    $IconFoldertest = test-path $IconFolder
    $iconFiletest = test-path "$IconFolder\$($Iconpath.Replace('.\',''))"
    $shortcut = $shell.CreateShortcut("$DesktopPath\$($Name).lnk")
    }
    Default {
    $IconFolder = "$env:LOCALAPPDATA\EUC\Icons"
    $IconFoldertest = test-path $IconFolder
    $iconFiletest = test-path "$IconFolder\$($Iconpath.Replace('.\',''))"
    $shortcut = $shell.CreateShortcut("$DesktopPath\$($Name).lnk")
    }
}


#sets the shortcut target
$shortcut.TargetPath = $Path

#sets the icon based on the setting chosen in $icon
switch ($Icon) {
    #If DefaultBrowser is selected, checks the default browser of the user and sets the icon to that
    'DefaultBrowser' { 
        $DefaultBrowser = Get-ChildItem 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\' | Get-ItemProperty | Select-Object -ExpandProperty ProgId
        if ($DefaultBrowser -like 'Chrome*') {
            if (Test-Path 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe') {
                $shortcut.IconLocation = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe,0'
            } 
            elseif (Test-Path 'C:\Program Files\Google\Chrome\Application\chrome.exe') {
                $shortcut.IconLocation = 'C:\Program Files\Google\Chrome\Application\chrome.exe,0'
            }
        } 
        elseif ($DefaultBrowser -like 'Firefox*') {
            if ( Test-Path "C:\Program Files (x86)\Mozilla Firefox\firefox.exe" ) {
                $shortcut.IconLocation = 'C:\Program Files (x86)\Mozilla Firefox\firefox.exe,0'
            } 
            elseif (Test-Path 'C:\Program Files\Mozilla Firefox\firefox.exe'){
                $shortcut.IconLocation = 'C:\Program Files\Mozilla Firefox\firefox.exe,0'
            }
        } 
        else {
            $shortcut.IconLocation = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe,0'
        }
     }
     #If any of the below are selected, set the approrpiate icon from the shell. 
    'File' { $shortcut.iconlocation = "shell32.dll,0" }
    'Folder' { $shortcut.iconlocation = "shell32.dll,4" }
    'Drive' { $shortcut.iconlocation = "shell32.dll,9" }
    'Chart' { $shortcut.iconlocation = "shell32.dll,21" }
    
    #if ico is selected it will check the previous icon related variables and create a path at #EUCIconPath to store the icon in and then sets it for the shortcut.
    'ico' { if($IconFoldertest -eq $False) {New-Item -path $IconFolder -ItemType Directory}
            if(($IconFiletest) -eq $False) {Copy-Item -path $Iconpath -Destination $IconFolder -Recurse}
            $shortcut.IconLocation = "$IconFolder\$($Iconpath.Replace('.\',''))"}
}
$shortcut.Save()
}

#Full command to create the shortcut, this can be ommited if you just want to load the function elsewhere but should be filled and uncommented for intunewim files. 
New-Shortcut -Name Test -Path "c:\Temp" -Desktop SystemStartMenu -Icon ico -Iconpath '.\shortcut.ico'
