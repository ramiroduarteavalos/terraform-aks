# Pod and a Service Example

This Terraform configuration creates a kubernetes pod and service in the namespace.

## Export environment variables to configure the Azure Terraform provider.

```bash
export ARM_SUBSCRIPTION_ID="x"
export ARM_TENANT_ID="x"
export ARM_CLIENT_ID="x"
export ARM_CLIENT_SECRET="x"
export TF_VAR_client_id=${ARM_CLIENT_ID}
export TF_VAR_client_secret=${ARM_CLIENT_SECRET}
```

## Usage

Run Terraform init, plan and apply

*Creating storage container to store Terraform state

```bash
az storage container create -n tfstate --account-name x --account-key x
```

```bash
terraform init -backend-config="storage_account_name=x" -backend-config="container_name=tfstate" -backend-config="access_key=x" -backend-config="key=codelab.microsoft.tfstate"
```

```bash
terraform validate
```

```bash
terraform plan -out out.plan
```

```bash
terraform apply out.plan
```

*Creating a kubernetes service of `Type=LoadBalancer` might take upwards of 3-5 mins since
Azure is creating a load balancer in the background and Terraform will wait for the
load balancer to be available.*

Check whether pod, service, and namespace is created successfully

```bash
kubectl get pods,services,namespace
```