# Azure MCS Storage Optimiser
Script to reduce Azure Storage costs by optimising MCS identity disks

When deploying a Citrix Machine Catalog in Azure using Premium storage, all disks are configured as Premium_LRS. The identity disk occupies approximately 16MB of data however when using Premium_LRS this is charged by as a 32GB SSD for *each* desktop.

A 32GB Premium_LRS disk costs around $5.50 per month, a 32GB Standard_LRS (HDD) disk costs around $1.70 giving you a 69% cost reduction!
Run this against 1,000 instances and you just saved $48,000 a year (for the IT Dept Christmas party fund?)

What the script does:

The script looks for any resource groups named using the automatic naming when Citrix creates your resource groups "citrix-xd-*" - this can be updated if you have manually created your resource groups, or if you want to do one at a time.

For each resource group we find, we get a list of the disks in the resource group and check:

 - How many disks are there
 - How many of those are identity disks (based on the inclusion of "-IdentityDisk-" in the name
 - How many of the identity disks are Premium_LRS based.
 
For each of the Premium identity disks we find we check if they are unattached - this indicates that the virtual desktop/server is off as on-demand provisioning will have removed the instance and left the disk behind. If the disk is unattached, we update the disk configuration to set the SKU to Standard_LRS.

Done.

Bear in mind, this is talking to Azure, so it can take a while to run through as it seems to average around 10 seconds for Azure to confirm the change.

Usage:

Please read the script before running. This will make changes to disk configurations without further confirmation, so make sure you are comfortable with what it is doing before running in a production environment!!

The script requires the "AZ" powershell modules - these can be downloaded following the instructions here https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-1.7.0

I have included but commented out the command to install it if you want to save time :)

Your powershell session needs to be authenticated to Azure. I have again included but commented out the command to do this as you may not need this depending on where you run it from.

This has been tested running from a client based powershell console, however equally can be used in the powershell Cloud Shell or in Azure Automation to the same effect.

Have fun, enjoy and let me know if you find any bugs or have any suggestions for improvement.

Bugs to: @andymc84 or amccullough84@gmail.com
