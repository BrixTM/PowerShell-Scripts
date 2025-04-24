function Install-NetworkPrinters {
    [CmdletBinding()]
    param (
    [Parameter(Mandatory)]
    [array]$Servers,
    [Parameter()]
    [array]$IgnorePrinters
    )
    #----------------------------------------------------------[Initialise]---------------------------------------------------------------------
    #Gets devices subnet details
    function get-subnet{
    #Checks PS version on the device and runs the appropriate command to get the device subnet
    if ($PSVersionTable.PSVersion.Major -ge 7){
            $IP = Test-Connection -ComputerName (hostname) -count 1 -IPv4
            (($IP.Address.IPAddressToString.Split(".")[0,1,2] -join (".")[0,1,2]).replace(" ","")+".")
        }
        else {
            $IP = Test-Connection -ComputerName (hostname) -count 1 
            (($IP.IPV4Address.IPAddressToString.Split(".")[0,1,2] -join (".")[0,1,2]).replace(" ","")+".")
        }
    }

    #Set Printers that match the user’s subnet
    function set-subnetprinters ($subnet){
        # Add users’ printers if any found
        if($null -ne ($subnet)){
            # Loop through Print servers
            foreach ($printer in $NetworkPrinters){
                # Add new printers
                add-printer -ConnectionName ("\\" + $printer.computername  + "\" + $printer.ShareName)
                Write-Output "Device is missing network printer, adding $($printer.name) on $($printer.PortName) to device" 
            }
        }
    }

    #Get all the local printers
    $LocalPrinters = get-printer

    #Get the subnet of the device
    $subnet = get-subnet

    #Get the network printers on the device that match $subnet
    $networkprinters = foreach ($server in $Servers){
        # Gather printers and them to variable
        get-printer -computername $server | Where-Object {$_.PortName -like "$subnet*" -and $_.Name -notlike $IgnorePrinters}
    }

    #----------------------------------------------------------[Start]---------------------------------------------------------------------
    #Checks if the subnet has network printers, if not exit with 0,
    #Checks if the printer is already installed on the device, if yes exit with code 0, otherwise Install printers that match the site subnet
    if ($null -ne $networkprinters) {
        $ComparedPrinters = Compare-Object -ReferenceObject $networkprinters -DifferenceObject $LocalPrinters -Property PortName -IncludeEqual
        if ($ComparedPrinters.sideindicator -contains "<="){
            set-subnetprinters -subnet $subnet
        }
        else {
            Write-Output "Detected Printers already installed on device" 
        }
    }
    else {
        Write-Output "Subnet has no printers on Print Servers"
    }
}