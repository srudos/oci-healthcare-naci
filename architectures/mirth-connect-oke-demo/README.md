# Deploy Mirth Connect on Oracle Kubernetes Engine (OKE)

This repository demonstrates how to deploy **Mirth Connect 4.5.2** on **Oracle Kubernetes Engine (OKE)** using **Terraform** and **Helm**. The deployment provisions the required Oracle Cloud Infrastructure (OCI) resources and deploys a production-ready Mirth Connect instance backed by **OCI PostgreSQL**.

The solution is organized into two independent Terraform stacks:

- **infra/** – Provisions the OCI infrastructure
- **apps/** – Deploys Mirth Connect onto the OKE cluster

---

## Repository Structure

```text
.
├── infra/
│   ├── networking.tf
│   ├── oke.tf
│   ├── database.tf
│   ├── vm.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── terraform.tfvars
│
├── apps/
│   ├── remote_state.tf
│   ├── kubeconfig.tf
│   ├── mirth_connect.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── helm/
│       └── mirth-connect/
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
│
└── README.md
```

---

## Features

- Infrastructure as Code using Terraform
- Oracle Kubernetes Engine (OKE)
- OCI PostgreSQL database
- Automatic database initialization
- Kubernetes Secret management
- Helm-based application deployment
- OCI Load Balancer integration
- Persistent storage
- Local Helm chart (no external chart dependency)

---

## Prerequisites

Before deploying, ensure you have:

- Oracle Cloud Infrastructure (OCI) account
- Terraform 1.5 or later
- OCI CLI configured
- kubectl
- Appropriate OCI IAM permissions

---

## Infrastructure Deployment

The **infra** stack provisions the following OCI resources:

- Virtual Cloud Network (VCN)
- Public and private subnets
- Internet Gateway
- NAT Gateway
- Security Lists / Network Security Groups
- Oracle Kubernetes Engine (OKE)
- Node Pool
- OCI PostgreSQL Database
- Optional Oracle Linux VM for administration or testing

Deploy the infrastructure:

```bash
cd infra

terraform init
terraform plan
terraform apply
```

Update `terraform.tfvars` with values appropriate for your OCI tenancy before applying the configuration.

---

## Application Deployment

After the infrastructure has been provisioned, deploy Mirth Connect:

```bash
cd ../apps

terraform init
terraform plan
terraform apply
```

The application stack performs the following tasks:

- Reads infrastructure outputs using Terraform remote state
- Generates kubeconfig for the OKE cluster
- Creates Kubernetes Secrets
- Initializes the PostgreSQL database
- Deploys Mirth Connect using the bundled Helm chart
- Creates a Kubernetes LoadBalancer Service

---

## Database Initialization

The deployment automatically initializes the PostgreSQL database.

The initialization job:

- Creates the Mirth Connect database
- Creates the application user
- Grants required privileges

No manual database setup is required.

---

## Accessing Mirth Connect

Retrieve the external IP address assigned to the Load Balancer:

```bash
kubectl get svc
```

Example output:

```text
NAME              TYPE           EXTERNAL-IP
mirth-connect     LoadBalancer   129.xxx.xxx.xxx
```

Access Mirth Connect using:

```
http://<LOAD_BALANCER_IP>:8080
```

or

```
https://<LOAD_BALANCER_IP>:8443
```

depending on your deployment configuration.

---

## Configuration

The deployment uses the official Mirth Connect container image:

```
docker.io/nextgenhealthcare/connect:4.5.2
```

Application configuration is managed through Kubernetes Secrets and includes:

- PostgreSQL JDBC connection
- Database credentials
- JVM options
- Keystore passwords
- Server configuration

---

## Persistent Storage

The Helm chart provisions a PersistentVolumeClaim for Mirth Connect application data.

Typical configuration:

| Property | Value |
|----------|-------|
| Access Mode | ReadWriteOnce |
| Storage | 10 Gi |

Adjust the storage class and capacity as needed for your environment.

---

## Deployment Workflow

```text
Terraform (infra)
        │
        ▼
Provision OCI Infrastructure
        │
        ▼
Terraform (apps)
        │
        ├── Read remote state
        ├── Generate kubeconfig
        ├── Create Kubernetes Secrets
        ├── Initialize PostgreSQL
        └── Deploy Helm chart
                │
                ▼
        Mirth Connect on OKE
```

---

## Cleanup

Destroy the application resources first:

```bash
cd apps
terraform destroy
```

Then remove the infrastructure:

```bash
cd ../infra
terraform destroy
```

---

## References

- [Oracle Kubernetes Engine Documentation](https://docs.oracle.com/iaas/Content/ContEng/home.htm)
- [OCI PostgreSQL Documentation](https://docs.oracle.com/iaas/Content/postgresql/home.htm)
- [Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Helm Documentation](https://helm.sh)

---

## Disclaimer

This repository is provided as a reference implementation for deploying Mirth Connect on Oracle Kubernetes Engine using Terraform and Helm. It is intended for demonstration and evaluation purposes. Before using this solution in production, review and implement appropriate security, monitoring, backup, scaling, and operational best practices.