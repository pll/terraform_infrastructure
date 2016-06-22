variable "aws_access_key"        {                                   }
variable "aws_secret_key"        {                                   }
variable "aws_key_name"          { default = "<SSH Keypair>"         }
variable "aws_region"            { default = "<Default Region>"      }

variable "availability_zones"    {
  default = "<Comma separated list of 3 default regions to use>"
}
  

variable "account_name"          {                                   }
variable "environment"           {                                   }
variable "vpc_bastion_user"      {                                   }
variable "owner"                 { default = "<Owner Name>"          }
variable "email"                 { default = "<Group Email>"         }
variable "group"                 { default = "<Group Tag>"           }

variable "puppet_tarball"        {                                   }
variable "ssh_user"              { default = "<username>"            }
variable "email"                 {                                   }
variable "vpc_cidr"              {                                   }
variable "pub_count"             {                                   }
variable "pub_offset"            {                                   }
variable "pri_count"             {                                   }
variable "pri_offset"            {                                   }
variable "number_of_nats"        { default = <Default # of nats>     }

variable "priv_dns_zone"         {                                   }
variable "region"                { default = "<Default Region>"      }
variable "amis"                  {  
    default {
        us-east1i = "ami-id"
        us-west-2 = "ami-id"
    }
}
variable "instance_type"         { default = "m3.medium"             }
variable "datacenter"            {                                   }
variable "datacenter_cidr"       {                                   } 
variable "datacenter_dns_1"      {                                   }
variable "datacenter_dns_2"      {                                   }
variable "datacenter_dns_zone"   { default = "<datacenter dns zone>" }

variable "aws_nat_ami"           {                                   }
variable "aws_nat_instance_type" {                                   }
variable "aws_vgw_exists"        { default = 0                       }
