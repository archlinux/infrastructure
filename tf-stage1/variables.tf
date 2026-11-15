variable "servers" {
  type = list(object({
    provider            = string
    zone                = string
    fqdn                = string
    type                = string
    subscription_period = optional(string, "hourly")
  }))

  validation {
    condition = alltrue([
      for server in var.servers :
      contains(["scaleway"], server.provider)
    ])
    error_message = "Provider must be scaleway."
  }
  validation {
    condition = alltrue([
      for server in var.servers :
      contains(["hourly", "monthly"], server.subscription_period)
    ])
    error_message = "Subscription period must be hourly or monthly."
  }
}
