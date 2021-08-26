variable "api_id" {
  type = string
}

variable "api_root_resource_id" {
  type = string
}

variable "path" {
  type = string
}

variable "response" {
  type = any
}

variable "method" {
  type    = string
  default = "GET"
}
