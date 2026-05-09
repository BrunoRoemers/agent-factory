# Docs: https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs

resource "hcloud_ssh_key" "dev_machine" {
  name       = "dev-machine-key"
  public_key = var.ssh_public_key
}

resource "hcloud_firewall" "openclaw" {
  name = "openclaw-fw"
}

resource "hcloud_server" "openclaw" {
  name        = "openclaw"
  server_type = "cx23"
  image       = "ubuntu-24.04"
  location    = "fsn1"

  ssh_keys     = [hcloud_ssh_key.dev_machine.id]
  firewall_ids = [hcloud_firewall.openclaw.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}

output "server_ip" {
  value = hcloud_server.openclaw.ipv4_address
}
