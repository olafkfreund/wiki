# Apache JMeter

#### Use secrets in Apache JMeter <a href="#jmeter_secrets" id="jmeter_secrets"></a>

In this section, you'll update the Apache JMeter script to use the secret that you specified earlier.

You first create a user-defined variable that retrieves the secret value. Then, you can use this variable in your test (for example, to pass an API token in an HTTP request header).

1.  Create a user-defined variable in your JMX file and assign the secret value to it by using the `GetSecret` custom function.

    The `GetSecret(<my-secret-name>)` function takes the secret name as an argument. You use this same name when you configure the load test in a later step.

    You can create the user-defined variable by using the Apache JMeter IDE, as shown in the following image:

    ![Screenshot that shows how to add user-defined variables to your Apache JMeter script.](https://learn.microsoft.com/en-us/azure/load-testing/media/how-to-parameterize-load-tests/user-defined-variables.png)

    Alternatively, you can directly edit the JMX file, as shown in this example code snippet:



    ```xml
    <Arguments guiclass="ArgumentsPanel" testclass="Arguments" testname="User Defined Variables" enabled="true">
      <collectionProp name="Arguments.arguments">
        <elementProp name="appToken" elementType="Argument">
          <stringProp name="Argument.name">udv_appToken</stringProp>
          <stringProp name="Argument.value">${__GetSecret(appToken)}</stringProp>
          <stringProp name="Argument.desc">Value for x-secret header </stringProp>
          <stringProp name="Argument.metadata">=</stringProp>
        </elementProp>
      </collectionProp>
    </Arguments>
    ```plaintext
2.  Reference the user-defined variable in the test script.

    You can use the `${}` syntax to reference the variable in the script. In the following example, you use the `udv_appToken` variable to set an HTTP header.



    ```xml
      <HeaderManager guiclass="HeaderPanel" testclass="HeaderManager" testname="HTTP Header Manager" enabled="true">
        <collectionProp name="HeaderManager.headers">
          <elementProp name="" elementType="Header">
            <stringProp name="Header.name">api-key</stringProp>
            <stringProp name="Header.value">${udv_appToken}</stringProp>
          </elementProp>
        </collectionProp>
      </HeaderManager>
    ```plaintext

### Configure load tests with environment variables <a href="#envvars" id="envvars"></a>

In this section, you use environment variables to pass parameters to your load test.

1. Update the Apache JMeter script to use the environment variable (for example, to configure the application endpoint hostname).
2. Configure the load test and pass the environment variable to the test script.

#### Use environment variables in Apache JMeter <a href="#use-environment-variables-in-apache-jmeter" id="use-environment-variables-in-apache-jmeter"></a>

In this section, you update the Apache JMeter script to use environment variables to control the script behavior.

You first define a user-defined variable that reads the environment variable, and then you can use this variable in the test execution (for example, to update the HTTP domain).

1.  Create a user-defined variable in your JMX file, and assign the environment variable's value to it by using the `System.getenv` function.

    The `System.getenv("<my-variable-name>")` function takes the environment variable name as an argument. You'll use this same name when you configure the load test.

    You can create a user-defined variable by using the Apache JMeter IDE, as shown in the following image:

    ![Screenshot that shows how to add user-defined variables for environment variables to your JMeter script.](https://learn.microsoft.com/en-us/azure/load-testing/media/how-to-parameterize-load-tests/user-defined-variables-env.png)

    Alternatively, you can directly edit the JMX file, as shown in this example code snippet:



    ```xml
    <Arguments guiclass="ArgumentsPanel" testclass="Arguments" testname="User Defined Variables" enabled="true">
      <collectionProp name="Arguments.arguments">
        <elementProp name="appToken" elementType="Argument">
          <stringProp name="Argument.name">udv_webapp</stringProp>
          <stringProp name="Argument.value">${__BeanShell( System.getenv("webapp") )}</stringProp>
          <stringProp name="Argument.desc">Web app URL</stringProp>
          <stringProp name="Argument.metadata">=</stringProp>
        </elementProp>
      </collectionProp>
    </Arguments>
    ```plaintext
2.  Reference the user-defined variable in the test script.

    You can use the `${}` syntax to reference the variable in the script. In the following example, you use the `udv_webapp` variable to configure the application endpoint URL.



    ```xml
    <stringProp name="HTTPSampler.domain">${udv_webapp}</stringProp>
    ```plaintext
