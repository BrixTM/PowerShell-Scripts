<p align="center"> 
    <img src="https://media.tenor.com/dc1V2uGIXgAAAAAj/seseren-blue-archive.gif" width="100"/> 
    <img src="https://media.tenor.com/dc1V2uGIXgAAAAAj/seseren-blue-archive.gif" width="100"/> 
    <img src="https://media.tenor.com/dc1V2uGIXgAAAAAj/seseren-blue-archive.gif" width="100"/> 
    <img src="https://media.tenor.com/dc1V2uGIXgAAAAAj/seseren-blue-archive.gif" width="100"/> 
    <img src="https://media.tenor.com/dc1V2uGIXgAAAAAj/seseren-blue-archive.gif" width="100"/> 
</p>

# PowerShell Scripts
This repo is just a collection of random scripts and functions I've created over time that I think are useful or have parts of them which are useful. Will probably update this from time to time with more random stuff.

## Scripts
All Folders are scripts, this may be one individual or a set of them used in something like an intune remediation or win32 package. Some of these may be used in tandem with functions in the function folder so keep an eye on the documentation for that. 

##### Install Print Server Printers
- Was initially a project wherein we migrated local printers to a print server for specific sites and installed the printers on the machines as an intune remediation.
- This script was converted into a fucntion for ease of use, I would recommend using that over these scripts, the remediation may still be useful.

##### New Desktop Shortcut (Uses Function)
- Useful set of scripts for creating win32 packages for shortcuts on users machines.
- Contains the Detection and uninstall/Install Commands, when using these make sure to change the Shortcut name to your one.
- Function in the function folder for the actual meat of this.

## Functions
This folder contains a bunch of functions I've made, some may be apart of other scripts in the parent Directory. I should update this when I add new functions with a description of them.

##### Get-ManagedDeviceDetails
- Used to gather information about devices from Intune and Azure using mgraph, this required the mgraph and mgraph beta PS modules to be present.
- Can search devices based of various different options such as Hostname, IMEI, OS, Serial Number, AzureID, IntuneID and ObjectID.
- Returns as a custom object that should be easy to work with and pass into other scripts.

##### Get-OutdatedAppManagedDevices
- Used to get a list of devices from intune with app versions older than what you specify
- The version number can be a bit messy depending on how apps handle their versioning, i would recommend testing -LT as [system.version] for your specific apps.

##### Install-NetworkPrinters
- Allows you to auto install printers from network print servers that match a devices subnet.
- Can filter out specific printers, for example if you use papercut you may want to filter out Follow Me printers.
- Will check if a printer is already installed and if there are no network printers on that subnet.
- There is a folder for this function in the Parent directory which contains earlier versions before I turned the app into a function, was used as an intune remediation.
- I need to comment this because I was lazy
- I also need to add the ability to exlude certain subnets from the search as I did in the original script. 

##### New-Shortcut
- Used to create a new shortcut for a User or System.
- Can be placed on the Users Start Menu and Desktop as well as System Start Menu and Desktop.
- Icons are stored in user or default appdata, change this if you want to store it in a different location. The folders should auto create as part of the function
