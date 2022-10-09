provider "kubernetes" {
    config_path="~/.kube/config"
}

resource "kubernetes_namespace" "products" {
    metadata {
        name = "products"
    }
}

resource "kubernetes_secret" "products_db" {
    metadata {
        name = "postgresdb"
        namespace = kubernetes_namespace.products.metadata.0.name
    }
    data = {
        DATABASE_URL=var.database_url
    }
    type = "Opaque"
}

resource "kubernetes_deployment" "products_deploy" {
    metadata {
        name = "products"
        namespace = kubernetes_namespace.products.metadata.0.name
    }
    spec {
        replicas = 1
        selector {
            match_labels = {
                app = "products_api"
            }
        }
        min_ready_seconds = 5
        strategy {
            type = "RollingUpdate"
            rolling_update {
                max_surge = 1
                max_unavailable = 1
            }
        
          
        }
        template {
            metadata {
                labels = {
                    app = "products_api"
                }
            }
            spec {
                container {
                    image = "scottyfullstack/basic-rest-api"
                    name = "products"
                    port {
                        container_port = 8000
                    }
                    env {
                        name = "DATABASE_URL"
                        value_from {
                            secret_key_ref {
                                key = "DATABASE_URL"
                                name = kubernetes_secret.products_db.metadata.0.name
                            }
                        }
                    }
                }
                volume {
                    name = "${kubernetes_secret.products_db.metadata.0.name}"
                    secret {
                        secret_name = "${kubernetes_secret.products_db.metadata.0.name}"
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "products_svc" {
    metadata {
        name="products-svc"
        namespace = kubernetes_namespace.products.metadata.0.name
    }
    spec {
        selector = {
            app = "${kubernetes_deployment.products_deploy.spec.0.template.0.metadata.0.labels.app}"
        }
        type = "NodePort"
        port {
            port = 8000
            target_port=8000
        }
    }
}