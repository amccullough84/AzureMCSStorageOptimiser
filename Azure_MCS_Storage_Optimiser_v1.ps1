# Author: Andy McCullough (@andymc84)
# Last Updated: 11/04/2019


#Uncomment Install the Azure "Az" Powershell Module
#Install-Module -Name Az -AllowClobber

#Disable Breaking Change notifications from AZ PowerShell Module
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

#Uncomment to Connect to Azure
#Connect-AzAccount | Out-Null

#Edit below to change the resource group scope
#Example: $RGs = Get-AzResourceGroup | Where ResourceGroupName -Like "my_citrix_resourcegroup_*"
$RGs = Get-AzResourceGroup | Where ResourceGroupName -Like "citrix-xd-*"

foreach( $RG in $RGs) {
  $RGName = $RG.ResourceGroupName
  Write-Host "Processing resource group: $RGName" -ForegroundColor Green
  #Get Disks in this resource Group
  $Disks = Get-AZDisk -ResourceGroupName $RGName
  If ($Disks.Count -gt 0) {
  $DiskCount = $Disks.Count
  Write-Host "  Found $DiskCount disks in resource group" -ForegroundColor Green

  $IdentityDisks = $Disks | Where Name -Like "*-IdentityDisk-*"
  $PremiumDisks = $IdentityDisks | Select -ExpandProperty Sku | Where Name -EQ "Premium_LRS"

  Write-Host "  Found $($IdentityDisks.Count) MCS Identity Disks" -ForegroundColor Green
  Write-Host "  Found $($PremiumDisks.Count) PREMIUM Identity Disks" -ForegroundColor Red
  
  If ($PremiumDisks.Count -gt 0) {
    ForEach ($Disk in $IdentityDisks) {
    #Only Process disks that are currently set to premium
    If ($Disk.Sku.Name -eq "Premium_LRS") {
      If ($Disk.DiskState -eq "Unattached") {
        Write-Host "    Processing Disk: $($Disk.Name)" -ForegroundColor Green
        New-AzDiskUpdateConfig -SkuName Standard_LRS | Update-AzDisk -ResourceGroupName $Disk.ResourceGroupName -DiskName $Disk.Name | Out-Null
      } Else {
        Write-Host "    Unable to Process Disk: $($Disk.Name) as it is in use." -ForegroundColor Magenta
      }
    
    }


    }
  }

  $Disks = Get-AZDisk -ResourceGroupName $RGName
  $IdentityDisks = $Disks | Where Name -Like "*-IdentityDisk-*"
  $PremiumDisks = $IdentityDisks | Select -ExpandProperty Sku | Where Name -EQ "Premium_LRS"
  Write-Host "After processing Found $($PremiumDisks.Count) PREMIUM Identity Disks" -ForegroundColor Green

  } Else {

  Write-Host "  No Disks found in resource group." -ForegroundColor Yellow

  }

}

Write-Host "Processing All Resource Groups Completed."
