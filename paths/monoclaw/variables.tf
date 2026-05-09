variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "ssh_public_key" {
  type = string
}

variable "tailscale_auth_key" {
  type      = string
  sensitive = true
}

variable "unix_username" {
  type    = string
  default = "app"
}
