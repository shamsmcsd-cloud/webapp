resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = "appi-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_service_plan" "this" {
  name                = "asp-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  worker_count        = var.worker_count
  tags                = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                = "app-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id

  https_only                               = true
  public_network_access_enabled            = true
  ftp_publish_basic_authentication_enabled = false
  # zip_deploy_file pushes to Kudu with the site's publishing credentials, so SCM basic auth must stay on.
  # If you move code deployment to the pipeline (azure/webapps-deploy with OIDC), set this to false.
  webdeploy_publish_basic_authentication_enabled = true

  # Deploys the app package. A new path (the file name carries a content hash) triggers a redeploy.
  zip_deploy_file = var.zip_deploy_file

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                         = var.always_on
    minimum_tls_version               = "1.2"
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5
    app_command_line                  = "gunicorn --bind=0.0.0.0:8000 --workers=2 --timeout=120 app:app"

    application_stack {
      python_version = var.python_version
    }
  }

  app_settings = merge(
    {
      APP_ENV                               = var.environment
      SCM_DO_BUILD_DURING_DEPLOYMENT        = "true" # App Service runs pip install -r requirements.txt
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.this.connection_string
    },
    var.app_settings,
  )

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "webapp" {
  name                       = "diag-app-${var.name}"
  target_resource_id         = azurerm_linux_web_app.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }
  enabled_log {
    category = "AppServiceConsoleLogs"
  }
  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
