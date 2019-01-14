## From shell.azure.com
## Using Powershell environment
## Create AKS cluster

if(!$args[0]){
    Write-Host "API Management name as the first parameter"
    Exit
}

$APIMNAME=$args[0]
$RGNAME="tdc2019-rg"
$REGION="westeurope"
$ORGANIZATIONNAME="TDC2019"
$EMAIL="noreply@temenos.com"

#Create the API Management instance
Write-Host "Creating resource group"
New-AzureRmResourceGroup -Name $RGNAME -Location $REGION -Confirm:$false
Write-Host "Creating API Management instance"
New-AzureRmApiManagement -ResourceGroupName $RGNAME -Location $REGION -Name $APIMNAME -Organization $ORGANIZATIONNAME -AdminEmail $EMAIL -Sku "Developer"

#Create the App Registration in Azure AD
Write-Host "Creating App Registration in Azure AD"
$APPNAME="$APIMNAME-app"
$IDURI="http://localhost/$APPNAME"
$CLIENTSECRET="TDC2019Secret!"
$REDIRECTURL1="https://$APIMNAME.portal.azure-api.net/docs/services/$APPNAME/console/openidconnect/implicit/callback"
$REDIRECTURL2="https://$APIMNAME.portal.azure-api.net/docs/services/$APPNAME/console/openidconnect/authorizationcode/callback"

az ad app create --display-name $APPNAME --oauth2-allow-implicit-flow true --password "$CLIENTSECRET" --identifier-uris "$IDURI" --reply-urls "$REDIRECTURL1" "$REDIRECTURL2" --required-resource-accesses "@manifest.json" 

#Configure OIDC provicer in API Management
Write-Host "Configure OIDC provider in API Management"
$APPID=$(az ad app show --id "$IDURI" --query 'appId' -o tsv)
Write-Host "Application Id: $APPID"
$TENANTID=$(az account show --query 'tenantId' -o tsv)
Write-Host "Tenant Id: $TENANTID"
$OPENIDCONFIG="https://login.microsoftonline.com/$TENANTID/.well-known/openid-configuration"
Write-Host "OIDC Config: $OPENIDCONFIG"

$apimContext = New-AzureRmApiManagementContext -ResourceGroupName "$RGNAME" -ServiceName "$APIMNAME"
New-AzureRmApiManagementOpenIdConnectProvider -Context $apimContext -OpenIdConnectProviderId "$APPNAME" -Name "$APPNAME" -ClientId "$APPID" -ClientSecret "$CLIENTSECRET" -MetadataEndpointUri "$OPENIDCONFIG"
New-AzureRmApiManagementProperty -Context $apimContext -PropertyId "OIDCProviderConfig" -Name "OIDCProviderConfig" -Value "$OPENIDCONFIG"