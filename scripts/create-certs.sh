#!/bin/bash

set -e

/etc/olcne/gen-certs-helper.sh \
--cert-request-organization-unit "Linux" \
--cert-request-organization "Oracle" \
--cert-request-locality "Raleigh" \
--cert-request-state "North Carolina" \
--cert-request-country US \
--cert-request-common-name ${dns_domain_name} \
--nodes ${control_plane_internal_fqdn},${worker1_internal_fqdn},${worker2_internal_fdqn}

# TODO: add id_rsa to control plane node
# chmod 644 /home/opc/configs/certificates/tmp-olcne/*/node.key
# bash -ex bash -ex /home/opc/configs/certificates/olcne-tranfer-certs.sh