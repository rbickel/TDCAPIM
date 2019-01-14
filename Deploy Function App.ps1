## From shell.azure.com
## Using Powershell environment
## Create Function App

if(!$args[0]){
    Write-Host "API Management name as the first parameter"
    Exit
}

$APPNAME=$args[0]
$RGNAME="tdc2019-rg"
$REGION="westeurope"

#create the resource group
az group create --name $RGNAME --location $REGION 
#create the storage account
az storage account create -n "$APPNAME" -g "$RGNAME" -l "$REGION" --sku Standard_LRS
#create the function app
az functionapp create -g "$RGNAME"  --consumption-plan-location "$REGION" -n "$APPNAME" -s "$APPNAME"

#retrieve the Kudu credentials to publish the functions
$creds = Invoke-AzureRmResourceAction -ResourceGroupName "$RGNAME" -ResourceType Microsoft.Web/sites/config -ResourceName $APPNAME/publishingcredentials -Action list -ApiVersion 2015-08-01 -Force
$username = $creds.Properties.PublishingUserName
$password = $creds.Properties.PublishingPassword
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

#Publish the functions
$apiUrl = "https://$APPNAME.scm.azurewebsites.net/api/zip/site/wwwroot"
$filePath = "Functions/Package.zip"
Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method PUT -InFile $filePath -ContentType "multipart/form-data"