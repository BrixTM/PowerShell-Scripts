function Get-MerakieNetworks {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        #Specifies the API Key to use
        [String]$APIKey,
        [Parameter(Mandatory)]
        #Specifies the organization ID to search
        [String]$OrgID,
        [Parameter()]
        #Specifies the API Key to use
        [string[]]$TagsToFilter
    )
    <#
        .SYNOPSIS
        Gets Clients connected to a specifies network from the Meraki API.

        .PARAMETER APIKey
        Specifies the API Key to verify access

        .PARAMETER OrgID
        Specifies Organisation ID of the desired Org to search

        .PARAMETER TagsToFilter
        Optional to filter the networks by tags, this must be in the following format
        'tag1,'tag2','tag3' including single quotes and comma

        .OUTPUTS
        Outputs a PSCustomObject for each Network.

        .EXAMPLE
        PS> Get-MerakiOfficeNetworks -APIKey "12345678987654321" OrgID "98765"

        .EXAMPLE
        PS> Get-MerakiOfficeNetworks -APIKey "12345678987654321" OrgID "98765" -TagsToFilter 'tag1','tag2'
    #--------------------------------------Start--------------------------------------#>

    #URI for Specific Query
    $GMON_URL = "https://api.meraki.com/api/v1/organizations/$OrgID/networks"

    #Headers for request
    $GMON_Headers = @{
        Accept         = "application/json"
        Authorization  = "Bearer $APIKey"
        'Content-Type' = 'application/json'
    }

    #Specifies body, this is only used with the TagsToFilter search and needs to be converted to JSON to work
    $GMON_Body = @{
        tags = @($TagsToFilter)
    }
    $GMON_jsonfix = $GMON_Body | ConvertTo-Json

    #Rest Get request sent to a variable and then returned depending on if FilterSearch is enabled, not using return does not return the object properly
    if ($TagsToFilter) {
        $GMON_networks = Invoke-RestMethod -Method Get -Uri $GMON_URL -Headers $GMON_Headers -Body $GMON_jsonfix 
    }
    else {
        $GMON_networks = Invoke-RestMethod -Method Get -Uri $GMON_URL -Headers $GMON_Headers
    }
    return $GMON_networks
}
#---------------------------------------------------------------------------------------------------------------------
function Get-MerakiVlans {
    param (
        [Parameter(Mandatory)]
        #Specifies the API Key to use
        [String]$APIKey,
        [Parameter(Mandatory)]
        #Specifies the Network ID to use
        [String]$NetworkID
    )
    <#
        .SYNOPSIS
        Gets VLANs from a specific network.

        .PARAMETER APIKey
        Specifies the API Key to verify access

        .PARAMETER NetworkID
        Specifies Network ID of the desired network to search

        .OUTPUTS
        Outputs a PSCustomObject for each device searched.

        .EXAMPLE
        PS> Get-MerakiNetworkClients -APIKey "123456789" -NetworkID "ID_987654321"
    #--------------------------------------Start--------------------------------------#>

    #URI for Specific Query
    $GMV_URL = "https://api.meraki.com/api/v1/networks/$NetworkID/appliance/vlans"

    #Headers for request
    $GMV_Headers = @{
        Accept         = "application/json"
        Authorization  = "Bearer $APIKey"
        'Content-Type' = 'application/json'
    }

    #Rest Get request sent to a variable and then returned, not using return does not return the object properly
    $GMV_Vlans = Invoke-RestMethod -Method Get -Uri $GMV_URL -Headers $GMV_Headers
    return $GMV_Vlans
}
#---------------------------------------------------------------------------------------------------------------------
function Get-MerakiNetworkClients {
    param (
        [Parameter(Mandatory)]
        #Specifies the API Key to use
        [String]$APIKey,
        [Parameter(Mandatory)]
        #Specifies the Network ID to use
        [String]$NetworkID
    )
    <#
        .SYNOPSIS
        Gets Clients connected to a specifies network from the Meraki API.

        .PARAMETER APIKey
        Specifies the API Key to verify access

        .PARAMETER NetworkID
        Specifies Network ID of the desired network to search

        .OUTPUTS
        Outputs a PSCustomObject for each device searched.

        .EXAMPLE
        PS> Get-MerakiNetworkClients -APIKey "123456789" -NetworkID "ID_987654321"
    #--------------------------------------Start--------------------------------------#>

    #URI for Specific Query
    $GMNC_URL = "https://api.meraki.com/api/v1/networks/$NetworkID/clients"

    #Headers for request
    $GMNC_Headers = @{
        Accept         = "application/json"
        Authorization  = "Bearer $APIKey"
        'Content-Type' = 'application/json'
    }

    #Body to ensure 5000 devices are pulled, if not included only 10 devices will be listed
    $GMNC_Body = @{
        perPage = "5000"
    }

    #Rest Get request sent to a variable and then returned, not using return does not return the object properly
    $GMNC_Clients = Invoke-RestMethod -Method Get -Uri $GMNC_URL -Headers $GMNC_Headers -Body $GMNC_Body 
    return $GMNC_Clients
}