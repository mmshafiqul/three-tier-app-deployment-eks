variable "key_name" {
    type = string
    description = "The name of the key pair"
}

variable "algorithm" {
    type = string
    description = "The algorithm of the key pair"
}

variable "rsa_bits" {
    type = number
    description = "The number of bits in the key pair"
}