variable "members" {
  type = list(object({
    email  = string
    junior = optional(bool, false)
  }))
}

variable "collections" {
  type = list(object({
    name    = string
    members = optional(list(string))
  }))
}
