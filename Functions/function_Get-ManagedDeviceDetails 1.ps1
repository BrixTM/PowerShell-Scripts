function Get-ManagedDeviceDetails {
    [CmdletBinding(DefaultParameterSetName = 'Specific')]
    param (
        [Parameter(Mandatory, ParameterSetName = "All")]
        #Allows you to search for all devices based on Operating System rather than a set list
        [switch]$SearchAll,
        [Parameter(Mandatory, ParameterSetName = 'Specific')]
        #Used to specify the Variable where the details on devices is held within Powershell
        [PSCustomObject]$SearchVariable,
        [Parameter(Mandatory, ParameterSetName = 'Specific')]
        [validateset('Hostname', 'IntuneID', 'AzureID', 'ObjectID', 'SerialNo', 'IMEI')]
        #Used to specify the type of search to perform based on the Hostname, IntuneID, AzureID or ObjectID
        [String]$SearchType,
        [Parameter(Mandatory, ParameterSetName = 'Specific')]
        #Used to specify the -SearchVariable Header to check against for -SearchType
        [String]$SearchHeader,
        [Parameter(Mandatory, ParameterSetName = "All")]
        #Specifies OS to search through if -SearchAll is selected
        [validateset('Windows', 'Android', 'iOS', 'MacOS', 'Linux', 'All')]
        [string]$OperatingSystem
    )
    <#
        .SYNOPSIS
        Get Various Device Details from Intune and Azure.

        .DESCRIPTION
        Version 4 (22/04/25)
        This script searches through Intune Azure and the mgraph API to gather various details about devices, it has the ability to search using
        Hostnames, IntuneID's, AzureID's and ObjectID's. This requires the following Permissions to mgraph which the function will request.
        - User.Read.All 
        - Group.ReadWrite.All
        - DeviceManagementManagedDevices.Read.All

        .PARAMETER SearchVariable
        Specifies the existing variable which contains the desired device details that are going to be searched for.

        .PARAMETER SearchHeader
        Specifies the Header of the SearchVariable to check against. Note that the Variable containing data MUST have a header.
        
        .PARAMETER SearchType
        Specifies what details you are providing to search against, this accepts Hostname, IntuneID, AzureID, ObjectID, SerialNo or IMEI.

        .PARAMETER SearchAll
        Allows you to search through All devices in Intune rather than a set list of devices.

        .PARAMETER OperatingSystem
        Specifies the operating system to search through when -SearchAll is used, this accpets Windows, Android, iOS, MacOS, Linux and All.

        .OUTPUTS
        Outputs a PSCustomObject for each device searched.

        .EXAMPLE
        PS> Get-DeviceDetails -SearchAll -OperatingSystem Android.

        .EXAMPLE
        PS> Get-DeviceDetails -SearchVariable $DeviceList -SearchType ObjectID -SearchHeader ObjectID.

        .EXAMPLE
        PS> Get-DeviceDetails -SearchVariable $DeviceList -SearchType IntuneID -SearchHeader ID.

        .EXAMPLE
        PS> Get-DeviceDetails -SearchVariable $DeviceList -SearchType AzureID -SearchHeader AzureAdDeviceId.

        .EXAMPLE
        PS> Get-DeviceDetails -SearchVariable $DeviceList -SearchType Hostname -SearchHeader DeviceName.

        .EXAMPLE
        PS> Get-DeviceDetails -SearchVariable $DeviceList -SearchType SerialNo -SearchHeader SerialNumber.

        .EXAMPLE
        PS> Get-DeviceDetails -SearchVariable $DeviceList -SearchType IMEI -SearchHeader IMEI.

        .EXAMPLE
        PS> Get-DeviceDetails -SearchVariable $DeviceList -SearchType AzureID -SearchHeader "Azure Device ID".

    #--------------------------------------Start--------------------------------------#>

    #Connect to Mgraph
    Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All", 'DeviceManagementManagedDevices.Read.All' -NoWelcome
    
    if ($SearchAll) {
        #Warns user that they'll be searching everything and provides status
        Write-Warning "This will query EVERY device in Intune and Azure, are you sure you want to Continue?" -WarningAction Inquire
        Write-Host "Warning acknowledged, this may take some time to complete."
        Write-Host "Gathering Devices Please Wait"
        #Searches through all devices based on chosen OS
        switch ($OperatingSystem) {
            Windows { $AllThingies = Get-MgBetaDeviceManagementManagedDevice -Filter "OperatingSystem eq 'Windows'" -All }
            Android { $AllThingies = Get-MgBetaDeviceManagementManagedDevice -Filter "OperatingSystem eq 'Android'" -All }
            iOS { $AllThingies = Get-MgBetaDeviceManagementManagedDevice -Filter "OperatingSystem eq 'iOS'" -All }
            MacOS { $AllThingies = Get-MgBetaDeviceManagementManagedDevice -Filter "OperatingSystem eq 'MacOS'" -All }
            Linux { $AllThingies = Get-MgBetaDeviceManagementManagedDevice -Filter "OperatingSystem eq 'Linux'" -All }
            All { $AllThingies = Get-MgBetaDeviceManagementManagedDevice -All }
        }
        #Gets Azure details of each device from $AllThingies and filters out any with invalid Azure ID's to prevent them being searched
        foreach ($thingy in $AllThingies) {
            $thingyIntune = $thingy
            Write-Progress -Activity "Gathering Device Details" -status "$($thingy.DeviceName)"
            switch ($thingy.AzureAdDeviceId) {
                "00000000-0000-0000-0000-000000000000" { $thingyAzure = $null }
                Default {
                    $ThingyAzure = Get-MgDeviceByDeviceId -DeviceId $thingy.AzureAdDeviceId
                }
            }
            #Gathers hardware info of the devices
            $ThingyHardware = Invoke-MgGraphRequest -Method GET -Uri ("https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($thingy.Id)" + '?$select=hardwareinformation')
            #Created custom object for each device searched
            [PSCustomObject]@{
                IntuneID         = $thingyIntune.Id
                AzureID          = if ($thingyIntune.AzureAdDeviceId -eq "00000000-0000-0000-0000-000000000000") { $null } else { $thingyIntune.AzureAdDeviceId }
                ObjectID         = $thingyAzure.ID
                DeviceType       = $thingyIntune.ChassisType
                Hostname         = $thingyIntune.DeviceName
                EnrolmentType    = $thingyIntune.DeviceEnrollmentType
                WiredIPV4        = if ($ThingyHardware.hardwareInformation.wiredIPv4Addresses) { ($ThingyHardware.hardwareInformation.wiredIPv4Addresses).replace("{", "") } else { "Empty" }
                WirelessIPV4     = if ($ThingyHardware.hardwareInformation.ipAddressV4) { ($ThingyHardware.hardwareInformation.ipAddressV4).replace("{", "") } else { "Empty" }
                OperatingSystem  = $thingyIntune.OperatingSystem
                OSVersion        = $thingyIntune.OSVersion
                Model            = $thingyIntune.Model
                SerialNumber     = $thingyIntune.SerialNumber
                Manufacturer     = $thingyIntune.Manufacturer
                IMEI             = if ($thingyIntune.IMEI) { $thingyIntune.IMEI } else { "N/A" }
                PrimaryUser      = $thingyIntune.UserDisplayName
                PrimaryUserEmail = $thingyIntune.EmailAddress
                UserID           = $thingyIntune.UserId
                LastSync         = $thingyIntune.LastSyncDateTime 
            }
            
        }
    }
    else {
        foreach ($thingy in $SearchVariable) {
            #skips any devices within provided data that are blank or null to speed up processing
            if ($Thingy.$SearchHeader -ne "" -and $null -ne $Thingy.$SearchHeader) {
                switch ($SearchType) {
                    'Hostname' {
                        #Searches Intune for devices that match the specific Hostname using the $searchHeader Specified
                        $thingyIntune = Get-MgBetaDeviceManagementManagedDevice -Filter "DeviceName eq '$($Thingy.$SearchHeader)'"
                        if ($thingyIntune) {
                            if ($thingyIntune.count -gt 1) {
                                $thingyIntune = $thingyIntune | Sort-Object -Property [date]LastSyncDateTime -Descending | Select-Object -First 1
                                Write-Warning "Multiple Devices found for $($Thingy.$SearchHeader). Returning Device with latest Sync Date, please validate manually."
                            }
                            #Uses the gathered AzureID from Intune to search the devices Azure Details
                            switch ($thingyIntune.AzureAdDeviceId) {
                                "00000000-0000-0000-0000-000000000000" { $thingyAzure = $null }
                                Default { $ThingyAzure = Get-MgDeviceByDeviceId -DeviceId $thingyIntune.AzureAdDeviceId }
                            }
                            #Queries mgraph API for hardware information
                            $ThingyHardware = Invoke-MgGraphRequest -Method GET -Uri ("https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($thingyIntune.Id)" + '?$select=hardwareinformation')
                        }
                    }
                    'IntuneID' {
                        #Searches Intune for devices that match the specific IntuneID using the $searchHeader Specified
                        $thingyIntune = Get-MgBetaDeviceManagementManagedDevice -ManagedDeviceId $thingy.$SearchHeader
                        #Uses the gathered AzureID from Intune to search the devices Azure Details
                        switch ($thingyIntune.AzureAdDeviceId) {
                            "00000000-0000-0000-0000-000000000000" { $thingyAzure = $null }
                            Default { $ThingyAzure = Get-MgDeviceByDeviceId -DeviceId $thingyIntune.AzureAdDeviceId }
                        }
                        #Queries mgraph API for hardware information
                        $ThingyHardware = Invoke-MgGraphRequest -Method GET -Uri ("https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($thingyIntune.Id)" + '?$select=hardwareinformation')
                    }
                    'AzureID' {
                        #Searches Azure for devices that match the specific AzureID using the $searchHeader Specified
                        $ThingyAzure = Get-MgDeviceByDeviceId -DeviceId $thingy.$SearchHeader
                        #Uses the gathered AzureID from Azure to search the devices Intune Details
                        $thingyIntune = Get-MgBetaDeviceManagementManagedDevice -Filter "AzureAdDeviceId eq '$($ThingyAzure.DeviceId)'"
                        #Queries mgraph API for hardware information
                        $ThingyHardware = Invoke-MgGraphRequest -Method GET -Uri ("https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($thingyIntune.Id)" + '?$select=hardwareinformation')
                    }
                    'ObjectID' {
                        #Searches Azure for devices that match the specific ObjectID using the $searchHeader Specified
                        $ThingyAzure = Get-MgDevice -Filter "ID eq '$($Thingy.$SearchHeader)'" 
                        #Uses the gathered AzureID from Azure to search the devices Intune Details
                        $thingyIntune = Get-MgBetaDeviceManagementManagedDevice -Filter "AzureAdDeviceId eq '$($ThingyAzure.DeviceId)'"
                        #Queries mgraph API for hardware information
                        $ThingyHardware = Invoke-MgGraphRequest -Method GET -Uri ("https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($thingyIntune.Id)" + '?$select=hardwareinformation')
                    }
                    'SerialNo' {
                        #Searches Intune for devices that match the specific Hostname using the $searchHeader Specified
                        $thingyIntune = Get-MgBetaDeviceManagementManagedDevice -Filter "SerialNumber eq '$($Thingy.$SearchHeader)'"
                        if ($thingyIntune) {
                            if ($thingyIntune.count -gt 1) {
                                $thingyIntune = $thingyIntune | Sort-Object -Property [date]LastSyncDateTime -Descending | Select-Object -First 1
                                Write-Warning "Multiple Devices found for $($Thingy.$SearchHeader). Returning Device with latest Sync Date, please validate manually."
                            }
                            #Uses the gathered AzureID from Intune to search the devices Azure Details
                            switch ($thingyIntune.AzureAdDeviceId) {
                                "00000000-0000-0000-0000-000000000000" { $thingyAzure = $null }
                                Default { $ThingyAzure = Get-MgDeviceByDeviceId -DeviceId $thingyIntune.AzureAdDeviceId }
                            }
                            #Queries mgraph API for hardware information
                            $ThingyHardware = Invoke-MgGraphRequest -Method GET -Uri ("https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($thingyIntune.Id)" + '?$select=hardwareinformation')
                        }
                    }
                    'IMEI' {
                        #Searches Intune for devices that match the specific Hostname using the $searchHeader Specified
                        $thingyIntune = Get-MgBetaDeviceManagementManagedDevice -Filter "IMEI eq '$($Thingy.$SearchHeader)'"
                        if ($thingyIntune) {
                            if ($thingyIntune.count -gt 1) {
                                $thingyIntune = $thingyIntune | Sort-Object -Property [date]LastSyncDateTime -Descending | Select-Object -First 1
                                Write-Warning "Multiple Devices found for $($Thingy.$SearchHeader). Returning Device with latest Sync Date, please validate manually."
                            }
                            #Uses the gathered AzureID from Intune to search the devices Azure Details
                            switch ($thingyIntune.AzureAdDeviceId) {
                                "00000000-0000-0000-0000-000000000000" { $thingyAzure = $null }
                                Default { $ThingyAzure = Get-MgDeviceByDeviceId -DeviceId $thingyIntune.AzureAdDeviceId }
                            }
                            #Queries mgraph API for hardware information
                            $ThingyHardware = Invoke-MgGraphRequest -Method GET -Uri ("https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($thingyIntune.Id)" + '?$select=hardwareinformation')
                        }
                    }
                }
                if ($null -ne $thingyIntune) {
                    Write-Progress -Activity "Gathering Device Details" -status "$($thingyIntune.DeviceName)"
                    #Creates custom object to output details in a desired format
                    [PSCustomObject]@{
                        SearchedTerm     = $thingy.$SearchHeader
                        IntuneID         = $thingyIntune.Id
                        AzureID          = if ($thingyIntune.AzureAdDeviceId -eq "00000000-0000-0000-0000-000000000000") { $null } else { $thingyIntune.AzureAdDeviceId }
                        ObjectID         = $thingyAzure.ID
                        DeviceType       = $thingyIntune.ChassisType
                        Hostname         = $thingyIntune.DeviceName
                        EnrolmentType    = $thingyIntune.DeviceEnrollmentType
                        WiredIPV4        = if ($ThingyHardware.hardwareInformation.wiredIPv4Addresses) { ($ThingyHardware.hardwareInformation.wiredIPv4Addresses).replace("{", "") } else { "Empty" }
                        WirelessIPV4     = if ($ThingyHardware.hardwareInformation.ipAddressV4) { ($ThingyHardware.hardwareInformation.ipAddressV4).replace("{", "") } else { "Empty" }
                        OperatingSystem  = $thingyIntune.OperatingSystem
                        OSVersion        = $thingyIntune.OSVersion
                        Model            = $thingyIntune.Model
                        SerialNumber     = $thingyIntune.SerialNumber
                        Manufacturer     = $thingyIntune.Manufacturer
                        IMEI             = if ($thingyIntune.IMEI) { $thingyIntune.IMEI } else { "N/A" }
                        PrimaryUser      = $thingyIntune.UserDisplayName
                        PrimaryUserEmail = $thingyIntune.EmailAddress
                        UserID           = $thingyIntune.UserId
                        LastSync         = $thingyIntune.LastSyncDateTime
                    }
                }
                else {
                    #If no device is found when searching Intune, return as an Invalid device with null data
                    Write-Host "Invalid Device $($thingy.$SearchHeader)"
                    [PSCustomObject]@{
                        SearchedTerm     = $thingy.$SearchHeader
                        IntuneID         = $Null
                        AzureID          = $Null
                        ObjectID         = $Null
                        DeviceType       = $Null
                        Hostname         = $Null
                        EnrolmentType    = $Null
                        WiredIPV4        = $Null
                        WirelessIPV4     = $Null
                        OperatingSystem  = $Null
                        OSVersion        = $Null
                        Model            = $Null
                        SerialNumber     = $Null
                        Manufacturer     = $Null
                        IMEI             = $Null
                        PrimaryUser      = $Null
                        PrimaryUserEmail = $Null
                        UserID           = $Null
                        LastSync         = $Null
                    }
                }
                #Clears variables each iteration to prevent objects containing incorrect data if they are null
                Clear-Variable thingy, thingyIntune, ThingyHardware, thingyAzure
            }
        }
    } 
}