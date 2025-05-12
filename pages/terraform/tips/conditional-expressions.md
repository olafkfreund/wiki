# Conditional Expressions

If you are used to traditional programming languages such as C#, Python, Java, etc., you’ll be familiar with the concept of _if / else_ statements. Terraform has no _if or else_ statement but instead uses ternary conditional operators.

The syntax of a conditional expression is as follows:

```hcl
condition ? true_val : false_val
```plaintext

A _conditional expression_ uses the value of a boolean expression to select one of two values. This expression evaluates to `true_val` if the value of `condition`is true, and otherwise, to `false_val`. This is the equivalent of an _If_-statement.

In Terraform, this logic is particularly useful when fed into the [`count`](https://spacelift.io/blog/terraform-count-for-each) statement to deploy multiple of resources. In Terraform, deploying 0 resources is also fine if the condition is not met.

### Example 1

For example, the statement below checks if the variable `var.server`is set to “UbuntuServer”. If it is true, then `count = 0` and will be deployed zero times. If it is set to anything else, then `count = 1`, and the resource will be deployed 1 time.

Note that Terraform does support traditional logical, equality, and comparison operators such as `==` (equal to) or `!=` (not equal to) `&&` (and), etc. [These operators](https://spacelift.io/blog/terraform-functions-expressions-loops) can be added together to make more complex conditionals.

```hcl
count = var.server == "UbuntuServer" ? 0 : 1
```plaintext

### Example 2

Another common use of conditional expressions is to define defaults to replace invalid values. The example below checks if the variable `var.server` is an empty string. If it is, then the value is “MicrosoftWindowsServer”. If not, then it is the actual value of `var.server` .

```hcl
var.server != "" ? var.server : "MicrosoftWindowsServer"
```plaintext

### Example 3

When creating a conditional expression, the two result types can be of any type. In the example below, we have an _integer_ of 100 if the condition is true, and a _string_ “UbuntuServer” if the condition is false.

```hcl
var.server ? 100 : "UbuntuServer"
```plaintext

However, this can cause confusion as Terraform will attempt to find a type that they can both convert to and make those conversions automatically if so. In the above case, both can be converted to a String.

To avoid this, writing the condition with a specific conversion function is recommended (see below using the `toString` function):

```hcl
var.server ? tostring(100) : "UbuntuServer"
```plaintext
