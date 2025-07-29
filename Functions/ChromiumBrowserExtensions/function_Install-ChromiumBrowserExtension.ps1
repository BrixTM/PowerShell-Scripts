
function Install-BrowserExtension {
    param (
        [Parameter(Mandatory)]
        #Specifies the Extension ID to install
        [String]$ExtensionID,
        [Parameter(Mandatory)]
        [validateset('Chrome', 'Edge')]
        #Specifies the browser the Extension is for
        [String]$Browser
    )
    #Gets the current user of the system so that we can identify their SID to modify only their profile in the registry
    $CurrentUser = ((Get-CimInstance -class Win32_ComputerSystem | Select-Object username).username) -replace '^[^\\]+\\', ''
    $UserAccounts = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
    $DesiredUser = foreach ($UserAccount in $UserAccounts) {
        Get-ItemProperty -path "Registry::$($UserAccount.name)" | Where-Object { $_.ProfileImagePath -match $CurrentUser }
    }
    #loops through each user identified that matches the current users username
    foreach ($User in $DesiredUser) {
        switch ($Browser) {
            'Chrome' {  
                #Tests if the registry Hive for browser extension install exists, if not create it
                if ((test-path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Google\Chrome\ExtensionInstallForcelist") -eq $false) {
                    New-Item -path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Google\Chrome\ExtensionInstallForcelist"
                }
                #Gets a list of all the currently installed extnesions then adds 1 to the total, this will then be used as the name for the registry key
                $installExtensions = Get-Item -path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Google\Chrome\ExtensionInstallForcelist" | Select-Object -ExpandProperty Property
                $ExetentionNumber = $installExtensions.count + 1
                #Creates a new registry key with the name being +1 of the total ammount of extensions and Value being the extention ID and download link for chrome extensions.
                New-ItemProperty -Path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name $ExetentionNumber -Value "$($ExtensionID);https://clients2.google.com/service/update2/crx"
            
            }
            'Edge' {
                #Tests if the registry Hive for browser extension install exists, if not create it
                if ((test-path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist") -eq $false) {
                    New-Item -path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist"
                }
                #Gets a list of all the currently installed extnesions then adds 1 to the total, this will then be used as the name for the registry key
                $installExtensions = Get-Item -path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" | Select-Object -ExpandProperty Property
                $ExetentionNumber = $installExtensions.count + 1
                #Creates a new registry key with the name being +1 of the total ammount of extensions and Value being the extention ID, edge policy does not need the link.
                New-ItemProperty -Path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -Name $ExetentionNumber -Value "$($ExtensionID)"
            
            }
        }
    }
}