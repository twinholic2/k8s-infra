variable "oidc_url" {
    default = ""
}

variable "client_id_list" {
    default = []
    type = list(string)
}

variable "name" {
    default = ""
}

variable "sa_name" {
    default = ""
}

variable "namespace" {
    default = ""
}

variable "policy_document_json" {
  default = ""
}