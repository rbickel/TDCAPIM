# TDCAPIM
Temenos Developer Conference: Azure API Management presentation

# Demo API Management

![TDC 2019 API Management demo](https://raw.githubusercontent.com/rbickel/TDCAPIM/master/APIManagement%20Demo.png)

## 1. Initial Setup
You need a clean API Management setup, with OpenID Connect provider configured. You can use the following script to do the setup:

1. Go to `shell.azure.com`
2. Switch the environment to `Powershell`
3. Execute the command `git clone https://github.com/rbickel/TDCAPIM`
4. Execute the script that will deploy the initial setup:
    ``` powershell
    cd
    #Ensure to update MYAPIMNAME with a unique name
    & './TDCAPIM/Deploy API Management.ps1' MYAPIMNAME
    ```
> The value of `MYAPIMNAME` must be unique globally

## 2. Import Calc API

Import calc API `http://calcapi.cloudapp.net/calcapi.json` following the official documentation: [Import and publish your API](https://docs.microsoft.com/en-us/azure/api-management/import-and-publish)

## 3. Enable Authentication
1. Select the API and go to the **Settings tab**
2. Under **Security**, select OpenID Connect provider for `Authorization`
3. Save your changes

## 3. API Policies for caching, json to xml and authorization
1. Select the API and go to the **Design tab**
2. Edit the policies and replace by the following xml
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

## Deploy Function App and Functions

1. Go to `shell.azure.com`
2. Switch the environment to `Powershell`
3. Execute the command `git clone https://github.com/rbickel/TDCAPIM`
4. Execute the script that will deploy the initial setup:
    ``` powershell
    cd
    cd 'TDCAPIM'
    #Ensure to update MYAPPNAME with a unique name. MYAPPNAME is also used for the storage account
    & './Deploy Function App.ps1' MYAPPNAME
    ```
> The value of `MYAPPNAME` must be unique globally. As it is used for the storage account, it must follow the stoage account naming restrictions.


## Extend the API Management APIs with Functions
1. Go to `portal.azure.com`
2. Select your `API Management` instance
3. Under `APIs`, select `...` next to your API > *Import* > *Function App*
4. Select the functions you want to import and click *Ok*