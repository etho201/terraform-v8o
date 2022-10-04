FROM oraclelinux:9-slim
LABEL maintainer="Erik Thomsen"

RUN microdnf install -y yum-utils && \
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo && \
    microdnf install -y terraform ansible-core

ENTRYPOINT ["/bin/bash"]