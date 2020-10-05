# oci-arch-tomcat-autonomous

Apache Tomcat® is an open source Java application server. It implements the Java Servlet, JavaServer Pages, Java Expression Language and Java WebSocket technologies.

## Terraform Provider for Oracle Cloud Infrastructure
The OCI Terraform Provider is now available for automatic download through the Terraform Provider Registry. 
For more information on how to get started view the [documentation](https://www.terraform.io/docs/providers/oci/index.html) 
and [setup guide](https://www.terraform.io/docs/providers/oci/guides/version-3-upgrade.html).

* [Documentation](https://www.terraform.io/docs/providers/oci/index.html)
* [OCI forums](https://cloudcustomerconnect.oracle.com/resources/9c8fa8f96f/summary)
* [Github issues](https://github.com/terraform-providers/terraform-provider-oci/issues)
* [Troubleshooting](https://www.terraform.io/docs/providers/oci/guides/guides/troubleshooting.html)

## Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-quickstart/oci-arch-tomcat-autonomous.git
    cd oci-arch-tomcat-autonomous
    ls

## Prerequisites
First off, you'll need to do some pre-deploy setup.  That's all detailed [here](https://github.com/cloud-partners/oci-prerequisites).

Setup TF_VAR_... to setup your environment

```
export TF_VAR_user_ocid=ocid1.user.oc1...
export TF_VAR_fingerprint=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
export TF_VAR_private_key_path=/path/to/private.key.pem
export TF_VAR_tenancy_ocid=ocid1.tenancy.oc1...
```

Secondly, create a `terraform.tfvars` file and populate with the following information:

```
# Authentication
tenancy_ocid         = "<tenancy_ocid>"

# SSH Keys
ssh_public_key  = "<public_ssh_key_path>"

# Region
region = "<oci_region>"

# Compartment
compartment_ocid = "<compartment_ocid>"

````

Deploy:

    terraform init
    terraform plan
    terraform apply

## Testing your deploymnet

After the deployment is finished, you can test that your tomcat was deployed correctly and can access the database going to the urls:

````
http://<load balancer IP>/JDBCSample/JDBCSample_Servlet

http://<load balancer IP>/JDBCSample/UCPServlet

`````

## Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy it:

    terraform destroy

## Tomcat-Autonomous Database Architecture

![](./images/architecture-deploy-tomcat.png)

Although the diagram shows a private subnet for the Tomcat servers, the scripts are provisioning them on a public subnet as there is no bastion to allow access to the servers.


## Reference Architecture

- [Deploy Apache Tomcat connected to an autonomous database](https://docs.oracle.com/en/solutions/deploy-tomcat-adb)
