# Advanced use of az-cli in bash

#### Using If Then Else to determine if variable is null <a href="#using-if-then-else-to-determine-if-variable-is-null" id="using-if-then-else-to-determine-if-variable-is-null"></a>

```bash
if [ $resourceGroup != '' ]; then
   echo $resourceGroup
else
   resourceGroup="msdocs-learn-bash-$randomIdentifier"
fi
```

#### Using If Then to create or delete a resource group <a href="#using-if-then-to-create-or-delete-a-resource-group" id="using-if-then-to-create-or-delete-a-resource-group"></a>

```bash
if [ $(az group exists --name $resourceGroup) = false ]; then 
   az group create --name $resourceGroup --location "$location" 
else
   echo $resourceGroup
fi
```

```bash
if [ $(az group exists --name $resourceGroup) = true ]; then 
   az group delete --name $resourceGroup -y # --no-wait
else
   echo The $resourceGroup resource group does not exist
fi
```

#### Using Grep to determine if a resource group exists, and create the resource group if it does not <a href="#using-grep-to-determine-if-a-resource-group-exists-and-create-the-resource-group-if-it-does-not" id="using-grep-to-determine-if-a-resource-group-exists-and-create-the-resource-group-if-it-does-not"></a>

{% code fullWidth="true" %}
```bash
az group list --output tsv | grep $resourceGroup -q || az group create --name $resourceGroup --location "$location"
```
{% endcode %}

#### Using CASE statement to determine if a resource group exists, and create the resource group if it does not <a href="#using-case-statement-to-determine-if-a-resource-group-exists-and-create-the-resource-group-if-it-doe" id="using-case-statement-to-determine-if-a-resource-group-exists-and-create-the-resource-group-if-it-doe"></a>

```bash
var=$(az group list --query "[? contains(name, '$resourceGroup')].name" --output tsv)
case $resourceGroup in
$var)
echo The $resourceGroup resource group already exists.;;
*)
az group create --name $resourceGroup --location "$location";;
esac
```

