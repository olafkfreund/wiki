# Querying dictionary results

```bash
az account show
az account show --output json # JSON is the default format
az account show --output yaml
az account show --output table
```plaintext

#### Querying and formatting single values and nested values <a href="#querying-and-formatting-single-values-and-nested-values" id="querying-and-formatting-single-values-and-nested-values"></a>

```bash
az account show --query name # Querying a single value
az account show --query name -o tsv # Removes quotation marks from the output

az account show --query user.name # Querying a nested value
az account show --query user.name -o tsv # Removes quotation marks from the output
```plaintext

#### Querying and formatting properties from arrays <a href="#querying-and-formatting-properties-from-arrays" id="querying-and-formatting-properties-from-arrays"></a>

{% code overflow="wrap" %}
```bash
az account list --query "[].{subscription_id:id, name:name, isDefault:isDefault}" -o table
```plaintext
{% endcode %}

#### Querying and formatting multiple values, including nested values <a href="#querying-and-formatting-multiple-values-including-nested-values" id="querying-and-formatting-multiple-values-including-nested-values"></a>

{% code overflow="wrap" %}
```bash
az account show --query [name,id,user.name] # return multiple values
az account show --query [name,id,user.name] -o table # return multiple values as a table
```plaintext
{% endcode %}

#### Renaming properties in a query <a href="#renaming-properties-in-a-query" id="renaming-properties-in-a-query"></a>

{% code overflow="wrap" %}
```bash
az account show --query "{SubscriptionName: name, SubscriptionId: id, UserName: user.name}" # Rename the values returned
az account show --query "{SubscriptionName: name, SubscriptionId: id, UserName: user.name}" -o table # Rename the values returned in a table
```plaintext
{% endcode %}

#### Querying Boolean values <a href="#querying-boolean-values" id="querying-boolean-values"></a>

{% code overflow="wrap" fullWidth="true" %}
```bash
az account list
az account list --query "[?isDefault]" # Returns the default subscription
az account list --query "[?isDefault]" -o table # Returns the default subscription as a table
az account list --query "[?isDefault].[name,id]" # Returns the name and id of the default subscription
az account list --query "[?isDefault].[name,id]" -o table # Returns the name and id of the default subscription as a table
az account list --query "[?isDefault].{SubscriptionName: name, SubscriptionId: id}" -o table # Returns the name and id of the default subscription as a table with friendly names

az account list --query "[?isDefault == \`false\`]" # Returns all non-default subscriptions, if any
az account list --query "[?isDefault == \`false\`].name" -o table # Returns all non-default subscriptions, if any, as a table

az account list --query "[?isDefault].id" -o tsv # Returns the subscription id without quotation marks
subscriptionId="$(az account list --query "[?isDefault].id" -o tsv)" # Captures the subscription id as a variable.
echo $subscriptionId # Returns the contents of the variable.
az account list --query "[? contains(name, 'Test')].id" -o tsv # Returns the subscription id of a non-default subscription containing the substring 'Test'
subscriptionId="$(az account list --query "[? contains(name, 'Test')].id" -o tsv) # Captures the subscription id as a variable. 
az account set -s $subscriptionId # Sets the current active subscription
```plaintext
{% endcode %}

#### Working with spaces and quotation marks <a href="#working-with-spaces-and-quotation-marks" id="working-with-spaces-and-quotation-marks"></a>

{% code lineNumbers="true" fullWidth="true" %}
```bash
resourceGroup='msdocs-learn-bash-$randomIdentifier'
echo $resourceGroup # The $ is ignored in the creation of the $resourceGroup variable
resourceGroup="msdocs-learn-bash-$randomIdentifier"
echo $resourceGroup # The $randomIdentifier is evaluated when defining the $resourceGroup variable
location="East US" # The space is ignored when defining the $location variable
echo The value of the location variable is $location # The value of the $location variable is evaluated
echo "The value of the location variable is $location" # The value of the $location variable is evaluated
echo "The value of the location variable is \$location" # The value of the $location variable is not evaluated
echo 'The value of the location variable is $location' # The value of the $location variable is not evaluated
az group create --name $resourceGroup --location $location # Notice that the space in the $location variable is not ignored and the command fails as it treats the value after the space as a new command 
az group create --name $resourceGroup --location "$location" # Notice that the space in the $location variable is ignored and the location argument accepts the entire string as the value
```plaintext
{% endcode %}

