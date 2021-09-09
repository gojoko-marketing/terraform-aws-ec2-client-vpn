variable "region" {
  type        = string
  description = "VPN Endpoints are region-specific. This identifies the region. AWS Region"
}

variable "client_cidr" {
  description = "Network CIDR to use for clients"
}

variable "aws_subnet_id" {
  type        = string
  description = "The Subnet ID to associate with the Client VPN Endpoint."
}

variable "aws_authorization_rule_target_cidr" {
  type        = string
  description = "The target CIDR address within your VPC that you would like to provider authorization for."
}

variable "logging_enabled" {
  type        = bool
  default     = false
  description = "Enables or disables Client VPN Cloudwatch logging."
}

variable "internet_access_enabled" {
  type        = bool
  default     = true
  description = <<-EOT
    Enables an authorization rule and route for the VPN to access the internet.
    Please note, you must allow ingress/egress to the internet (0.0.0.0/0) via the Subnet's security group.
  EOT
}

variable "organization_name" {
  type        = string
  description = "Name of organization to use in private certificate"
}

variable "retention_in_days" {
  description = "Number of days you want to retain log events in the log group"
  default     = "30"
}

variable "logging_stream_name" {
  type        = string
  description = "Names of stream used for logging"
}

variable "basic_constraints" {
  description = <<-EOT
    The [basic constraints](https://datatracker.ietf.org/doc/html/rfc5280#section-4.2.1.9) of the issued certificate.
    Currently, only the `CA` constraint (which identifies whether the subject of the certificate is a CA) can be set.
    Defaults to this certificate not being a CA.
  EOT
  type = object({
    ca = bool
  })
  default = {
    ca = false
  }
}

variable "validity" {
  description = <<-EOT
    Validity settings for the issued certificate:
    `duration_hours`: The number of hours from issuing the certificate until it becomes invalid.
    `early_renewal_hours`: If set, the resource will consider the certificate to have expired the given number of hours before its actual expiry time (see: [self_signed_cert.early_renewal_hours](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert#early_renewal_hours)).
    Defaults to 10 years and no early renewal hours.
  EOT
  type = object({
    duration_hours      = number
    early_renewal_hours = number
  })
  default = {
    duration_hours      = 87600
    early_renewal_hours = null
  }
}

variable "saml_metadata_document" {
  default     = null
  description = "Optional SAML metadata document. Must include this or `saml_provider_arn`"
  type        = string
}

variable "saml_provider_arn" {
  default     = null
  description = "Optional SAML provider ARN. Must include this or `saml_metadata_document`"
  type        = string

  validation {
    error_message = "Invalid SAML provider ARN."

    condition = (
      var.saml_provider_arn == null ||
      try(length(regexall(
        "^arn:aws:iam::(?P<account_id>\\d{12}):saml-provider/(?P<provider_name>[\\w+=,\\.@-]+)$",
        var.saml_provider_arn
        )) > 0,
        false
    ))
  }
}

variable "additional_routes" {
  default     = []
  description = "A list of additional routes that should be attached to the Client VPN endpoint"

  type = list(object({
    destination_cidr_block = string
    description            = string
    target_vpc_subnet_id   = string
  }))
}

variable "additional_security_groups" {
  default     = []
  description = "List of security groups to attach to the client vpn network associations"
  type        = list(string)
}

variable "associated_subnets" {
  type        = list(string)
  description = "List of subnets to associate with the VPN endpoint"
}

variable "authorization_rules" {
  type = list(object({
    name                 = string
    access_group_id      = string
    authorize_all_groups = bool
    description          = string
    target_network_cidr  = string
  }))
  description = "List of objects describing the authorization rules for the client vpn"
}
