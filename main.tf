terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "4.95.0"
    }
  }
}

provider "oci" {
  # API Key Authentication
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

# Generate SSH Key Pair for access
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_sensitive_file" "ssh_private_key" {
  filename = "${path.module}/auth/${var.instance_name}/id_rsa"
  file_permission = "600"
  content = tls_private_key.ssh.private_key_pem
}

# Get a list of Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = "${var.compartment_ocid}"
}

# Create OCI core instance for the OCNE control node
resource "oci_core_instance" "control_plane" {
  depends_on = [
    tls_private_key.ssh
  ]
  display_name = "${var.instance_name}-control-plane"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
  compartment_id = "${var.compartment_ocid}"
  shape = "VM.Standard.E4.Flex"
  shape_config {
    ocpus = 4
    memory_in_gbs = 48
  }

  source_details {
      source_id = "${var.os_image_ocid}"
      source_type = "image"
  }
  create_vnic_details {
      assign_public_ip = true
      subnet_id = var.subnet_ocid
  }
  metadata = {
      ssh_authorized_keys = tls_private_key.ssh.public_key_openssh
      user_data = "${base64encode(file("./scripts/cloud-init-control-plane.sh"))}"
  }

  provisioner "remote-exec" {
    inline = ["cloud-init status --wait > /dev/null"]
  }

  connection {
    type     = "ssh"
    user     = "opc"
    private_key = tls_private_key.ssh.private_key_pem
    host     = self.public_ip
  }

  provisioner "file" {
    source      = "./scripts/create-certs.sh"
    destination = "/tmp/create-certs.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "export dns_domain_name=${data.oci_core_subnet.my_subnet.subnet_domain_name}",
      "export control_plane_internal_fqdn='${oci_core_instance.control_plane.hostname_label}.${data.oci_core_subnet.my_subnet.subnet_domain_name}'",
      "export worker1_internal_fqdn='${oci_core_instance.worker_nodes["1"].hostname_label}.${data.oci_core_subnet.my_subnet.subnet_domain_name}'",
      "export worker2_internal_fdqn='${oci_core_instance.worker_nodes["2"].hostname_label}.${data.oci_core_subnet.my_subnet.subnet_domain_name}'",
      "chmod +x /tmp/create-certs.sh",
      "/tmp/create-certs.sh",
    ]
  }
}

# Create server nodes
resource "oci_core_instance" "worker_nodes" {
  for_each = toset( ["1", "2"] )
  depends_on = [
    tls_private_key.ssh
    # local.node_token,
    # oci_core_network_security_group_security_rule.k3s_api_server,
    # oci_core_network_security_group_security_rule.k3s_ha_embedded_etcd
  ]
  display_name        = "${var.instance_name}-worker${each.key}"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
  compartment_id      = var.compartment_ocid
  shape = "VM.Standard.E4.Flex"

  source_details {
    source_id   = var.os_image_ocid
    source_type = "image"
  }
  shape_config {
    ocpus = 1
    memory_in_gbs = 16
  }
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = var.subnet_ocid
    # nsg_ids          = [var.nsg_ocid]
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.ssh.public_key_openssh
    user_data = "${base64encode(file("./scripts/cloud-init-workers.sh"))}"
  }

  provisioner "remote-exec" {
    inline = ["cloud-init status --wait > /dev/null"]
  }

  connection {
    type     = "ssh"
    user     = "opc"
    private_key = tls_private_key.ssh.private_key_pem
    host     = self.public_ip
  }
}

output "connection_details" {
  value = format("ssh -i ./auth/${var.instance_name}/id_rsa opc@%s", oci_core_instance.control_plane.public_ip)
  description = "Details how to connect using the public IP address of the instance."
}

locals {
  k3s_server_ip = oci_core_instance.control_plane.public_ip
  worker_node_1_ip = oci_core_instance.worker_nodes["1"].public_ip
  worker_node_2_ip = oci_core_instance.worker_nodes["2"].public_ip
  # node_token = data.external.get_node_token.result.node_token
}

resource "local_sensitive_file" "readme" {
  filename = "${path.module}/auth/${var.instance_name}/control-plane.md"
  content = oci_core_instance.control_plane.public_ip
}
resource "local_sensitive_file" "worker1" {
  filename = "${path.module}/auth/${var.instance_name}/worker1.md"
  content  = local.worker_node_1_ip
}

resource "local_sensitive_file" "worker2" {
  filename = "${path.module}/auth/${var.instance_name}/worker2.md"
  content  = local.worker_node_2_ip
}

data "oci_core_subnet" "my_subnet" {
    #Required
    subnet_id = var.subnet_ocid
}
