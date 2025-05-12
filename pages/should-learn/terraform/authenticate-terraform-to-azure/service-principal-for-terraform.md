# Service Principal for terraform

{% code overflow="wrap" lineNumbers="true" %}
```bash
#!/usr/bin/env bash
#set -x

# Creates service principal with contributor role to your subscription

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SP_NAME="firstContainerAppGitHubAction"
az ad sp create-for-rbac --name $SP_NAME --role "contributor" --scopes "/subscriptions/$SUBSCRIPTION_ID" --sdk-auth  --output json
servicePrincipalAppId=$(az ad sp list --display-name $SP_NAME --query "[].appId" -o tsv)
az role assignment create --assignee $servicePrincipalAppId --role "User Access Administrator" --scopes "/subscriptions/$SUBSCRIPTION_ID"
```plaintext
{% endcode %}

this is the output:

```json
{
  "clientId": "XXXXXX",
  "clientSecret": "XXXXXX",
  "subscriptionId": "XXXXXX",
  "tenantId": "XXXXXX",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```plaintext
