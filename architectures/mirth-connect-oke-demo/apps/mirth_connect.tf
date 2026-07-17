############################################################
# Mirth Connect config + DB init job + Helm release (apps)
# This stack expects infra to be applied first.
############################################################

locals {
  mirth_db_name = "mirthdb"

  mirth_db_url = format(
    "jdbc:postgresql://%s:%d/%s",
    data.terraform_remote_state.infra.outputs.postgres_primary_fqdn,
    data.terraform_remote_state.infra.outputs.postgres_primary_port,
    local.mirth_db_name
  )
}

############################################################
# Kubernetes secret with Mirth Connect environment variables
# The official image supports DATABASE, DATABASE_URL, DATABASE_USERNAME,
# DATABASE_PASSWORD, DATABASE_MAX_RETRY, DATABASE_RETRY_WAIT,
# KEYSTORE_STOREPASS, KEYSTORE_KEYPASS, VMOPTIONS, and SERVER_ID.
############################################################

resource "kubernetes_secret_v1" "mirth_env" {
  metadata {
    name      = "mirth-connect-env"
    namespace = "default"
  }

  data = {
    DATABASE                  = "postgres"
    DATABASE_URL              = local.mirth_db_url
    DATABASE_USERNAME         = var.psql_mirth_username
    DATABASE_PASSWORD         = var.psql_mirth_password
    DATABASE_MAX_CONNECTIONS  = tostring(var.mirth_database_max_connections)
    DATABASE_MAX_RETRY        = tostring(var.mirth_database_max_retry)
    DATABASE_RETRY_WAIT       = tostring(var.mirth_database_retry_wait_ms)
    KEYSTORE_STOREPASS        = var.mirth_keystore_storepass
    KEYSTORE_KEYPASS          = var.mirth_keystore_keypass
    VMOPTIONS                 = var.mirth_vmoptions
    SERVER_ID                 = var.mirth_server_id
  }

  type = "Opaque"
}

############################################################
# DB initialization (creates database and user for Mirth Connect)
############################################################

resource "kubernetes_secret_v1" "mirth_db_init" {
  metadata {
    name      = "mirth-db-init-secret"
    namespace = "default"
  }

  data = {
    admin_username = var.psql_admin_username
    admin_password = var.psql_admin_password
    db_username    = var.psql_mirth_username
    db_password    = var.psql_mirth_password
    db_name        = local.mirth_db_name
  }

  type = "Opaque"
}

/*
resource "time_sleep" "wait_for_oke" {
  depends_on      = [data.oci_containerengine_cluster_kube_config.this]
  create_duration = "120s"
}
*/
resource "kubernetes_job_v1" "init_mirth_db" {
  depends_on = [
    # time_sleep.wait_for_oke,
    kubernetes_secret_v1.mirth_db_init
  ]

  metadata {
    name      = "init-mirth-db"
    namespace = "default"
  }

  spec {
    backoff_limit = 3

    template {
      metadata {}
      spec {
        # restart_policy = "OnFailure"
        restart_policy = "Never"

        container {
          name  = "psql-init"
          # image = "postgres:15"
          image = "docker.io/library/postgres:15"

          env {
            name  = "PGHOST"
            value = data.terraform_remote_state.infra.outputs.postgres_primary_fqdn
          }
          env {
            name  = "PGPORT"
            value = tostring(data.terraform_remote_state.infra.outputs.postgres_primary_port)
          }
          env {
            name = "PGUSER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.mirth_db_init.metadata[0].name
                key  = "admin_username"
              }
            }
          }
          env {
            name = "PGPASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.mirth_db_init.metadata[0].name
                key  = "admin_password"
              }
            }
          }
          env {
            name = "DB_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.mirth_db_init.metadata[0].name
                key  = "db_username"
              }
            }
          }
          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.mirth_db_init.metadata[0].name
                key  = "db_password"
              }
            }
          }
          env {
            name = "DB_NAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.mirth_db_init.metadata[0].name
                key  = "db_name"
              }
            }
          }

          command = ["/bin/sh", "-c"]
          args = [<<-EOT
            set -eu

            echo "Waiting for PostgreSQL..."
            until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER"; do sleep 5; done

            echo "Creating database/user (idempotent)..."
            psql -v ON_ERROR_STOP=1 \
                -d postgres \
                -v db_name="$DB_NAME" \
                -v db_user="$DB_USERNAME" \
                -v db_pass="$DB_PASSWORD" <<'SQL'

            -- Create role if it does not exist
            SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'db_user', :'db_pass')
            WHERE NOT EXISTS (
                SELECT 1 FROM pg_roles WHERE rolname = :'db_user'
            )
            \gexec

            SELECT format('GRANT %I TO %I', :'db_user', current_user)
            WHERE NOT EXISTS (
            SELECT 1
            FROM pg_auth_members m
            JOIN pg_roles r ON r.oid = m.roleid
            JOIN pg_roles u ON u.oid = m.member
            WHERE r.rolname = :'db_user'
                AND u.rolname = current_user
            )
            \gexec

            -- Create database if it does not exist
            SELECT format('CREATE DATABASE %I OWNER %I', :'db_name', :'db_user')
            WHERE NOT EXISTS (
                SELECT 1 FROM pg_database WHERE datname = :'db_name'
            )
            \gexec

            SQL
          EOT
          ]
        }
      }
    }
  }
}

############################################################
# Helm release
############################################################

resource "helm_release" "mirth_connect" {
  depends_on = [
    kubernetes_secret_v1.mirth_env,
    kubernetes_job_v1.init_mirth_db
  ]

  name      = "mirth-connect"
  namespace = "default"

  chart = "${path.module}/helm/mirth-connect"

  values = [yamlencode({
    replicaCount = var.mirth_replica_count

    image = {
      repository = var.mirth_image_repository
      tag        = var.mirth_image_tag
    }

    service = {
      httpPort       = var.mirth_http_port
      httpsPort      = var.mirth_https_port
      targetHttpPort = var.mirth_http_port
      targetHttpsPort = var.mirth_https_port
    }

    persistence = {
      size              = var.mirth_persistence_size
      storageClassName  = var.mirth_persistence_storage_class
    }
  })]

  wait    = true
  timeout = 600
}
