# Intro

## Prerequisites <a href="#f54a" id="f54a"></a>

1. A Kubernetes cluster ( Can be either On-Prem, AKS, EKS, GKE, Kind ).
2. An AWS account.

### Story Resources <a href="#596f" id="596f"></a>

1. **GitHub Link**: [https://github.com/olafkfreund/crossplane-terraform-manifests/](https://github.com/olafkfreund/crossplane-terraform-manifests/tree/crossplane)
2. **GitHub Branch**: crossplane

### Install Cross plane in a Kubernetes Cluster <a href="#5172" id="5172"></a>

You can use an existing Kubernetes cluster for this demo. Alternatively, you can also install a Kubernetes cluster using kind or using GitHub actions. You can refer to my previous articles on how to create a Kubernetes cluster using

1. **GitHub actions**
2. [**Kind**](https://medium.com/nerd-for-tech/create-a-kubernetes-cluster-using-kind-b364a67437b7)

### Resources <a href="#5bb3" id="5bb3"></a>

1. GitHub Link: [https://github.com/olafkfreund/crossplane-terraform-manifests/tree/crossplane](https://github.com/olafkfreund/crossplane-terraform-manifests/tree/crossplane)

Once you have the Kubernetes cluster created let us now install Crossplane in our cluster. You can clone my repo with the crossplane branch for all the manifests used in this article.

<pre><code><strong>###Clone the repo git clone  -b crossplanecd medium-manifests/crossplane-aws#Create the namespace and install the components using helmkubectl create namespace crossplane-system
</strong>
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update

<strong>helm install crossplane --namespace crossplane-system crossplane-stable/crossplane#Check the components are up and healthy kubectl get all -n crossplane-system                            ( OR ) git clone  -b crossplanecd medium-manifests/crossplane-awsmake install_crossplane 
</strong></code></pre>

Alternatively, you can also use a makefile that I have written. This will install kind in your MAC / Linux machines, create a Kind cluster and then install crossplane in the Kind cluster.

Let us now install the AWS Provider. This will Install all the CRD’s ( Custom Resources Definitions ) required to create resources on the cloud. Ex: **rdsinstances.database.aws.crossplane.io**, **ec2.aws.crossplane.io/v1alpha1,** etc.

```
kubectl apply -f aws-provider.yaml 
```

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*C_gpn4Fd9UtFLYbQDm3TXg.png" alt="" height="147" width="700"><figcaption><p>Provider Package</p></figcaption></figure>

<pre><code><strong>###Once you install the Provider, wait for the Provider to be healthy by executingkubectl get provider.pkg 
</strong></code></pre>

Once the Provider is healthy let us now configure the Provider to communicate with AWS by creating a `ProviderConfig` definition. Make sure that you have already configured your credentials using **AWS configure ( From the cli, if you are running the commands from a local cluster ).**

<pre><code><strong>###Generate the configuration files with the AWS Credentials. AWS_PROFILE=default &#x26;&#x26; echo -e "[default]\naws_access_key_id = $(aws configure get aws_access_key_id --profile $AWS_PROFILE)\naws_secret_access_key = $(aws configure get aws_secret_access_key --profile $AWS_PROFILE)" > creds.conf###Create a Kubernetes secret with the configuration file generated. kubectl create secret generic aws-secret-creds -n crossplane-system --from-file=creds=./creds.conf###Once the secret is created let us now create the Provider config for our AWS account.kubectl apply -f provider-config.yaml 
</strong></code></pre>

Upon successful creation, your local cluster should now be able to communicate with AWS. Let us now try creating the following scenario. Let us create a VPC and a Security Group that would allow access from Port 3306 from anywhere from the world. Let us simultaneously create an RDS and attach the aforementioned SG to the same RDS Instance so that it would be publically accessible. Once this resource is created we will create a pod in our local cluster and check if it can access the RDS Instance. Seems good? Let us now get into action.

Let us create a VPC in the us-east-1 region with the below-mentioned spec.

<pre><code><strong>kubectl apply -f aws-vpc.yaml ###Let us check the status of the VPC. We are now referring to the provider created earlier in ( line no 20 ). kubectl get vpc
</strong></code></pre>

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*DrsOGw3FiCha8NhO2tm8Pg.png" alt="" height="126" width="700"><figcaption><p>VPC created with VPC ID and CIDR block and the sync and Ready state</p></figcaption></figure>

Once our VPC is successfully created let us create 2 subnets and attach an internet gateway to our VPC and also add a Route table for the same so that we can create our RDS in these Public subnets and then access from our local pod. However this is not the suggested method in Production, you should never spin your RDS in a Public Subnet in a Production environment.

<pre><code><strong>kubectl apply -f aws-subnet.yaml###Let us check the status of the subnets.kubectl get subnets
</strong></code></pre>

Let us now create the corresponding Internet gateway and Route table.

<pre><code><strong>kubectl apply -f aws-igwrt.yaml###Let us check the status of the Route table and Internet Gatewaykubectl get InternetGateway,RouteTable
</strong></code></pre>

Let us now create the security group that would allow communication over port 3306 to the Internet. Later we will attach this security group to our RDS Instance.

<pre><code><strong>kubectl apply -f aws-sg.yaml###Let us check the status of the Route table and Internet Gatewaykubectl get SecurityGroup
</strong></code></pre>

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*s35lMKs0V4sg2oLajJsiYQ.png" alt="" height="79" width="700"><figcaption><p>Security group created in the afore-mentioned VPC.</p></figcaption></figure>

Let us now create the RDS instance, but before we do that we would need a subnet group in which the RDS instance has to be created. We will use the subnets created earlier in the DB Subnet Group.

<pre><code><strong>kubectl apply -f aws-rds.yaml###Let us check the status of the RDS Instance. The credentials are stored in a secret called production-rds-conn-string in the default namespace. ( line no 56 ) kubectl get RDSInstance
</strong></code></pre>

Now let us try to access our Mysql RDS Instance. We can access this by decoding the secret **production-rds-conn-string** created in the default namespace. You can connect to the database using the MySQL client

> mysql -h \<hostname> -u \<user\_name> -p \<password>

Alternatively, you can spin up a pod and connect from the pod itself.

<pre><code><strong>###Create a testpod that shows all the databases in the RDS Instance
</strong><strong>kubectl apply -f aws-rds-connection-test.yaml 
</strong></code></pre>

You should now see the databases in the logs of the Pod.

Throughout the article we have hardcoded the names, we also have an option to filter the resources using tags. But for some reason, my resources were not being filtered even after tagging them. If you were able to filter them using the tags please feel free to paste the solution in the comments section.

Source: [https://medium.com/nerd-for-tech/introduction-to-crossplane-2f873ae0f9f3](https://medium.com/nerd-for-tech/introduction-to-crossplane-2f873ae0f9f3)
