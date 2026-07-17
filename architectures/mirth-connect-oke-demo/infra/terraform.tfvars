# =========================
# Network / Access
# =========================
public_allowed_ips = [
  "xx.xx.xx.xx/32",      # Office
  "xx.xx.xx.xx/32"     # Home
]

vcn_cidr             = "10.0.0.0/16"
public_subnet_cidr   = "10.0.1.0/24"
private_subnet_cidr  = "10.0.2.0/24"

# =========================
# OCI Authentication
# =========================
tenancy_ocid      = "<oci_tenancy_ocid>"
user_ocid         = "<oci_user_ocid>"
fingerprint       = "<api_key_fingerprint>"
private_key_path  = "<local_path_to_your_api_private_key>"
region            = "<oci_region>"
compartment_ocid  = "<compartment_ocid>"



# =========================
# SSH
# =========================
ssh_public_key_path = "<local_path_to_your_ssh_public_key>"

# =========================
# OKE Cluster
# =========================
cluster_name                 = "demo-oke-cluster"
cluster_kubernetes_version   = "v1.36.0"
node_pool_size   = 1
node_shape       = "VM.Standard.E5.Flex"
node_ocpus       = 1
node_memory_gbs  = 8

# using "Oracle-Linux-8.10-2026.04.30-3-OKE-1.36.0-1462"
node_image_ocid = "ocid1.image.oc1.iad.aaaaaaaa4oxftqqja3omtzreqdr4d7yophhp4iriopirvwakkoc2pxrylduq"
# =========================
# Object Storage
# =========================
bucket_name = "demo-oke-bucket"

customer_secret_key_display_name = "demo-oke-accesskey"

# =========================
# PostgreSQL DB System
# =========================
psql_admin_username = "<set_psql_admin_username_here>"
psql_admin_password = "<set_psql_admin_password_here>"
# psql_mirth_username = "<set_psql_mirth_db_username_here>"
# psql_mirth_password = "<set_psql_mirth_db_password_here>"

psql_db_version = "15"
psql_shape      = "PostgreSQL.VM.Standard.E5.Flex"
psql_ocpus      = 2
psql_memory_gbs = 16

# =========================
# Test VM
# =========================
# using "Oracle-Linux-8.10-2025.11.20-0"
test_vm_image_ocid = "ocid1.image.oc1.iad.aaaaaaaazigqixefhjb6jew2etuzox5erpff6wjtjhe5lzextgxm76jymz2q"

