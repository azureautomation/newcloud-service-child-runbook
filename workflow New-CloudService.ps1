<# 
.SYNOPSIS  
     An Azure Automation Runbook to create a new cloud service. No benefit over New-AzureService
 
.DESCRIPTION 
    This runbook creates a new cloud service. Used just to clean up new environment runbook and
    standardise cloud service creation.Not much benefit over New-AzureService

    Can be used with New-StorageAccount and New-AvailabilityGroupVM to automate environment creation
 
.PARAMETER Name
    The project name = The Cloud Service Name. 
 
.PARAMETER CredentialName 
    The name of the Azure Automation Credential Asset.
    This should be created using 
    http://azure.microsoft.com/blog/2014/08/27/azure-automation-authenticating-to-azure-using-azure-active-directory/  
 
.PARAMETER AzureSubscriptionName 
    The name of the Azure Subscription. 
 
.PARAMETER Location 
    The Location for the Storage Account 
    Current Options (January 2015)
        West Europe, North Europe, East US 2,Central US,South Central US,West US,North Central US                                                                                                                                                   
        East US,Southeast Asia,East Asia,Japan West,Japan East,Brazil South 	
 
.EXAMPLE 
    New-CloudService -Name ProjectName -CredentialName MasterCredential -AzureSubscriptionName SubName -Location 'North Europe' 
    
    This will create a Cloud Service named ProjectName in North Europe

.OUTPUTS
    None
 
.NOTES 
    AUTHOR: Rob Sewell sqldbawithabeard.com 
    DATE: 04/01/2015 
#> 

workflow New-CloudService
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$CredentialName,
        [Parameter(Mandatory=$true)]
        [string]$AzureSubscriptionName,
        [Parameter(Mandatory=$true)]
        [string]$Location
    )

    # Get the credential to use for Authentication to Azure and Azure Subscription Name
    $Cred = Get-AutomationPSCredential -Name $CredentialName
    
    # Connect to Azure and Select Azure Subscription
    $AzureAccount = Add-AzureAccount -Credential $Cred
    $AzureSubscription = Select-AzureSubscription -SubscriptionName $AzureSubscriptionName

    $Desc = "The Cloud Service for $Name"
    $Label = "Project $Name"
    $Service = Get-AzureService -ServiceName $Name -ErrorAction SilentlyContinue

        if(!$Service) 
            {
            $Service = New-AzureService -ServiceName $Name -Description $Desc -Label $Label -Location $Location
            $VerboseMessage = "{0} for {1} {2} (OperationId: {3})" -f $Service.OperationDescription,$Name,$Service.OperationStatus,$Service.OperationId
            } 
        else 
            { 
            $VerboseMessage = "Azure Cloud Serivce {0}: Verified" -f $Service.ServiceName 
            }

        Write-Output "$VerboseMessage"

} 

