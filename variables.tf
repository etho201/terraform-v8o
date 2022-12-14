variable "tenancy_ocid" {
  description = "OCID of your tenancy"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of target compartment within tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the user calling the API"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint for the key pair being used"
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key file"
  type        = string
}

variable "region" {
  description = "An OCI region"
  type        = string
}

variable "vcn_ocid" {
  description = "The OCID of the VCN (required for OCNE)"
  type        = string
}

variable "subnet_ocid" {
  description = "The OCID of the subnet to create the VNIC in"
  type        = string
}

variable "instance_name" {
  description = "A user-friendly name. Does not have to be unique, and it's changeable."
  type        = string
  default     = "My first IaC instance"
}

variable "os_image_ocid" {
  description = "The OCID for the OS image."
  type        = string
  default     = "ocid1.image.oc1.iad.aaaaaaaasdqmcux7p5sdhhsqygmfzf2n6smemihykfv4bv7qh4235zre75da"
}