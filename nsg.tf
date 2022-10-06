resource "oci_core_network_security_group_security_rule" "insecure" {
    network_security_group_id = oci_core_network_security_group.insecure_network_security_group.id
    direction = "INGRESS"
    protocol = "all"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "web" {
    network_security_group_id = oci_core_network_security_group.web_network_security_group.id
    direction = "INGRESS"
    protocol = "6"

    description = "Web (http)"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            min = 80
            max = 80
        }
    }
}

resource "oci_core_network_security_group_security_rule" "websecure" {
    network_security_group_id = oci_core_network_security_group.web_network_security_group.id
    direction = "INGRESS"
    protocol = "6"

    description = "Websecure (https)"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            min = 443
            max = 443
        }
    }
}