terraform {
  backend "http" {
    update_method = "PUT"
    address       = "https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/E52C5qefLDdzgGOUmHOTdqN5nfNTLUldk6EN8BWtCL4/n/oscemea005/b/terraform-state/o/terraform.tfstate"
  }
}
