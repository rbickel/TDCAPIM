# TDCAPIM
Temenos Developer Conference: Azure API Management presentation

# Demo API Management

![TDC 2019 API Management demo](https://raw.githubusercontent.com/rbickel/TDCAPIM/master/APIManagement%20Demo.png)

## Initial Setup
You need a clean API Management setup, with OpenID Connect provider configured. You can use the following script to do the setup:

1. Go to `shell.azure.com`
2. Switch the environment to `Powershell`
3. Execute the command `git clone https://github.com/rbickel/TDCAPIM`
4. Execute the script that will deploy the initial setup:
    ``` powershell
    cd
    & './TDCAPIM/Deploy API Management.ps1'
    ```

##n Calc API Import

Import calc API `http://calcapi.cloudapp.net/calcapi.json` following the official documentation: [Import and publish your API](https://docs.microsoft.com/en-us/azure/api-management/import-and-publish)

## API Policies

```xml
<policies>
    <inbound>
        <base />
        <validate-jwt 
            header-name="Authorization" 
            failed-validation-httpcode="401" 
            failed-validation-error-message="Unauthorized" 
            require-expiration-time="true" 
            require-scheme="Bearer" 
            require-signed-tokens="true" 
            clock-skew="0">
            <openid-config url="{{OIDCProviderConfig}}" />
        </validate-jwt>
        <cache-lookup 
            vary-by-developer="false" 
            vary-by-developer-groups="false" 
            allow-private-response-caching="true" downstream-caching-type="none">
            <vary-by-header>Accept</vary-by-header>
        </cache-lookup>
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
        <xml-to-json kind="direct" apply="always" consider-accept-header="true" />
        <cache-store duration="3600" />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
```
