### Tenant details oscemea005
tenancy                 = "oscemea005"
tenancy_ocid            = "ocid1.tenancy.oc1..aaaaaaaabe6z7dwwq2xjr3rdbagxtjjy2nlg74qu3lbdhtcyczx3hh3i22iq"
### User
user_ocid               = "ocid1.compartment.oc1..aaaaaaaanp5u4sxx5gdj2e62gkmz4otwhze37uaq7gw2j4prridg4pyuzq6q"
### Compartment Name
compartment_ocid        = "ocid1.user.oc1..aaaaaaaayhe2o3n3ze3aonwtdn6t4f4hms34nkxytuneh6nzkymyuz774c2q"
### API Fingerprint
fingerprint             = "8f:c9:da:f9:0d:7e:38:e8:f2:84:5f:98:58:f5:fb:de"
### Path to private API key
private_key_path        = "${HOME}/.oci/oscemea005_api_key.pem"
### Region we work in
region                  = "eu-frankfurt-1"
### Authorized public IPs ingress
### you can limit access by assigning e.g. 90.119.107.2/32
### considering that this IP is your current public IP
### you can validate your current public IP by opening http://iplocation.net in your browser
### if you put above example only you woudl be able to ssh in after deployment
authorized_ips          = "0.0.0.0/0"
### Variables for VM Creation
#BootStrapFile_ol7       = "userdata/bootstrap_ol7"
ssh_public_key     = $(cat ~/.ssh/torsten.pub)
ssh_private_key    = $(cat ~/.ssh/torsten)
