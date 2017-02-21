#login to Azure and select subscription for creation of objects

Login-AzureRmAccount

Get-AzureRmSubscription

Select-AzureRmSubscription –Subscriptionid “Provide Your Subscription ID Here”

$Cred = Get-Credential #Must Be Complex – Contains uppercase, lowercase, numeric, AND special character

$VMName = “EDUDC01”

$RGName = “ADFSDeployment“

$StorageAccount = Get-AzureRmStorageAccount –ResourceGroupName $RGName -Name “adfsedu01”

$OSDiskName = $VMName + “_OSDisk“ #Name of ‘to be’ created VHD.

$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + “vhds/” + $OSDiskName + “.vhd“ #Name of ‘to be’ name & path of new VHD.

$AVSet = Get-AzureRmAvailabilitySet –ResourceGroupName $RGName -Name “AVSet-DC”

$Location = “West US 2”

#If Using An Azure Image

Get-AzureRmVMImage -Location “West US 2” –PublisherName “MicrosoftWindowsServer“ -Offer “WindowsServer“ –Skus “2012-R2-Datacenter” #Use to list current versions

$Publisher = “MicrosoftWindowsServer“

$Offer = “WindowsServer“

$Sku = “2012-R2-Datacenter”

$Version = “4.0.20160812” #Update with current version

#If Using HUB Benefit & Bring Your Own Image

$URIOfUploadedImage = $StorageAccount.PrimaryEndpoints.Blob.ToString() + “images/2012R2.vhd” #Location of Template VHD

#Networking Setup

$Vnet = Get-AzureRmVirtualNetwork -Name “EDUNets“ –ResourceGroupName $RGName

$SubnetProduction = Get-AzureRmVirtualNetworkSubnetConfig -Name “Production” –VirtualNetwork $vNet

$NIC = New-AzureRmNetworkInterface –ResourceGroupName $RGName -Name “vNIC–$VMname-Prod” -Subnet $SubnetProduction -Location $Location –PrivateIpAddress 172.16.1.5

#Define VM Configuration

$VMConfig = New-AzureRmVMConfig –VMName $VMName –VMSize “Standard_DS2_V2” –AvailabilitySetId $AVSet.id |

Set-AzureRmVMOperatingSystem -Windows –ComputerName $VMName -Credential $Cred –ProvisionVMAgent –EnableAutoUpdate |

Set-AzureRmVMSourceImage –PublisherName $Publisher -Offer $Offer –Skus $Sku -Version $Version |

Set-AzureRmVMOSDisk -Name “$VMName-OSDISK” –VhdUri $OSDiskUri –CreateOption fromImage -Caching ReadOnly |  #To Bring Your Own Image, Add ‘-SourceImageUri $URIOfUploadedImage‘ |

Add-AzureRmVMNetworkInterface -Id $NIC.Id -Primary | Set-AzureRmVMBootDiagnostics -Enable –ResourceGroupName $RGName –StorageAccountName “edudiagnostics“

#Create VM

New-AzureRmVM –ResourceGroupName $RGName -Location $Location -VM $VMConfig
