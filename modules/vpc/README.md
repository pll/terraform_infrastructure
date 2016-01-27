# ce_vpc - Terraform VPC module

This module is designed to create a VPC complete with N public
subnets, M private subnets, basic security groups, an Internet Gateway
(IGW) and an optional VPN Gateway (VGW)

## AWS Configuration Variables

- **aws_access_key**

  AWS API Access Key Name.

- **aws_secret_key**

  AWS API Access Key Secret.

- **aws_region**

  The AWS region to build the VPC in.

- **availability_zones**

  Comma-separated list of AWS Availability Zones to spread subnets
  across.  This comma-separated list will be split and indexed into
  using Terraform functions element() and split()


## Generic Variables used for tagging all the things
- **owner**

  Name of the person or group responsible for this VPC.

- **email**

  Email contact of the person or group responsible for this VPC.

- **group**

  Group or Billable Entity this VPC should be charged to for billing purposes.

- **env**

  Environment or name of this VPC. e.g: coral, topaz, malachite, lapis

- **account**

  AWS Account this VPC should be created in.


## Network config settings
- **vpc_cidr**

  The CIDR notation of the network block to be used.
  e.g.: 10.1.2.0/16, 192.168.1.0/24, etc.

- **pub_count**

  Number of public, internet facing subnets to create.
  Default = 3

- **pub_offset**

  Index into a list of possible network blocks which exist in vpc_cidr.
  Default = 0

- **pri_count**

  Number of private, non-internet facing subnets to create.
  Default = 3

- **pri_offset**

  Index into a list of possible network blocks which exist in vpc_cidr.
  Default = 8

  We assume a VPC CIDR block with a /16 subnet mask and subnets with a
  /20 netmask.  This means in a /16 we can fit 16 /20s.  With 3 subnets
  each on the public and private sides. Therefore we split the 16
  possible subnets in half and place the public nets in the bottom half
  (beginning with X.Y.0.0/20) and the privates in the top half
  (beginning at X.Y.128.0/20).

  To use something other than the defaults, you need to know the following:

  - what size subnets do you want to create; /20s, /21s, /24s, etc.

  - how many subnets you wish to create.

  - the total possible number of subnets of this size available in
    a /16 (or whatever size your VPC CIDR block is.

- **datacenter**

  The name of the datacenter environment associated with this VPC.
  This assumes there is a Direct Connect back to a datacenter.  Any
  string will work here if you're not using a Direct Connect.

- **datacenter_cidr**

  CIDR Block of the datacenter to connect to over a DirecConnect,
  assuming there is one.  This will be used in route tables.  If there
  is no DirectConnect, this will not be used, so any string should
  (will?) work.

- **vpc_vgw_exists**

  Whether or not to create a VPN Gateway.  This is a boolean, either 1 or 0

# Output Variables

This module provides the following output variables to be consumed and used by any code which includes it:

- **private_ids (private-nets.tf)**

  Description:  Subnet IDs of private subnets.
  Type:         Comma-separated string
  
- **private_cidrs (private-nets.tf)**

  Description:  CIDR block addresses of private subnets.
  Type:         Comma-separated string

- **public_ids (public-nets.tf)**

  Description:  Subnet IDs of public subnets.
  Type:         Comma-separated string

- **public_cidrs (public-nets.tf)**

  Description:  CIDR block addresses of public subnets.
  Type:         Comma-separated string

- **nat_sg (security-groups.tf)**

  Description:  Security Group ID for NAT traffic
  Type:         String
   
- **datacenter_sg (security-groups.tf)**

  Description:  Security Group ID for VPC<->Datacenter traffic
  Type:         String
   
- **igw_id (vpc.tf)**

  Description:  Internet Gateway ID
  Type:         String
   
- **vpc_name (vpc.tf)**

  Description:  VPC Name tag value
  Type:         String   

- **vpc_id (vpc.tf)**

  Description:  VPC ID
  Type:         String

- **vpc_cidr (vpc.tf)**

  Description:  CIDR block address (same value as passed in via var.vpc_cidr)
  Type:         String
   
- **vpc_vgw_name (vpc.tf)**

  Description:  VGW Name tag value for VPN Gateway (for DirectConnect traffic)
  Type:         String
   
- **vpc_vgw_id (vpc.tf)**

  Description:  VGW ID
  Type:         String



# Example usage:

Assume the following code is located in a file called `main.tf` :

```
module "vpc" {
    source             = "git::ssh://git@github.com:<user>/terraform/modules/vpc.git"
    env                = "<environment name>"
    account            = "<aws account name>"

    # Passed in on command line via -var="aws_access_key"
    aws_access_key     = "${var.aws_access_key}"
    # Passed in on command line via -var="aws_secret_key"
    aws_secret_key     = "${var.aws_secret_key}"

    aws_region         = "<preferred region>"
    availability_zones = "<comma separated list of 3 AZs>"

    vpc_cidr           = "<preferred CIDR Block>"
    pub_count          = "<Number of public subnets>"
    pub_offset         = "<Index into list of subnets in CIDR block>"

    pri_count          = "<Number of private subnets>"
    pri_offset         = "<Index into list of subnets in CIDR block>"

    vpc_vgw            = "<do we want a VGW? Yes=1 or No=0>"
    datacenter         = "<datacenter environment name>"
    datacenter_cidr    = "<datacenter CIDR block>"
}
```

The above settings would most likely be set in a var-file passed into terraform on the command line via -var-file=<path to var file>".  An example var-file might look like this:

```
environment        = "qa-aws"
account_name       = "qa-nonproduction"
aws_region         = "us-east-1"
availability_zones = "us-east-1a,us-east-1b,us-east-1c"
vpc_cidr           = "10.128.0.0/16"
pub_count          = "3"
pub_offset         = "0"
pri_count          = "8"
pri_offset         = "1"
aws_vgw            = "1"
datacenter         = "qa-datacenter"
datacenter_cidr    = "10.1.0.0/16"
```

We'll assume this var file is in a sub-directory called var-files, and is named after the `environment`. Therefore, we'd have a path of `var-files/topaz`. Given those assumptions, our main.tf might actually look like this:

```
module "vpc" {
    source             = "git::ssh://git@github.com:<user>/terraform/modules/vpc.git"
    env                = "${var.environment}"
    account            = "${var.account_name}"
    aws_access_key     = "${var.aws_access_key}"
    aws_secret_key     = "${var.aws_secret_key}"
    aws_region         = "${var.aws_region}"
    availability_zones = "${var.availability_zones}"

    vpc_cidr           = "${var.vpc_cidr}"
    pub_count          = "${var.pub_count}"
    pub_offset         = "${var.pub_offset}"

    pri_count          = "${var.pri_count}"
    pri_offset         = "${var.pri_offset}"

    vpc_vgw            = "${var.aws_vgw}"
    datacenter         = "${var.datacenter}"
    datacenter_cidr    = "${var.datacenter_cidr}"
}

```

Notice too, that `aws_access_key` and `aws_secret_key` are not present in the var-file. It's bad practice to store AWS credentials in a file, so we'll assume you'll pass them in using the `-var=''` option to terraform.  Given this configuration, we could run terraform like this:

```
$ terraform apply -var="aws_access_key=XXX" -var="aws_secret_key=YYY"
```

# Notes about networks

When defining networks, we need only to set the base CIDR block for the VPC in a variable `vpc_cidr`. e.g.: `vpc_cidr = "10.160.0.0/16"`. We also need to specify the number of both public and private subnets we want to use.  We would do that using the following configuration:

```
    vpc_cidr           = "${var.vpc_cidr}"
    pub_count          = "${var.pub_count}"
    pri_count          = "${var.pri_count}"
```

Terraform provides a function `cidrsubnet()` to then determine which subnets you want to use. From the terraform documentation, `cidrsubnet()` is defined like this:

> cidrsubnet(iprange, newbits, netnum) - Takes an IP address range in CIDR notation (like 10.0.0.0/8) and extends its prefix to include an additional subnet number. For example, cidrsubnet("10.0.0.0/8", 8, 2) returns 10.2.0.0/16.

What this is attempting to say is this:

- iprange : Provide the top level CIDR block you wish to carve subnets out of. In our example case we'd use `"10.160.0.0/16"`.
- newbits : The difference between the number of bits in the netmask for your carved out subnets and the number of bits used in `iprange`. e.g. if you wanted to use /24s, or normal Class C subnets, `newbits` would be equal to '24 - 16', or '8'.
- netnum : An index to the position in an array of networks carved out of the `iprange` block based on the value of `newbits`.

Let me provide an example.  Let's assume we want to use /20s as our network size and we're setting up the VPC with a /16.  `20 - 16 = 4`, therefore, `newbits = 4` as well. So, by calling `cidrsubnet("10.160.0.0/16", 4, netnum)` we're telling `terraform` to return the CIDR block for a /20 carved out of the provided /16.

Now all we need to do is tell `terraform` **which** of those 16 subnets to use.  Picture the list of possible subnets as an array:

```
  Network[1]  = 10.160.0.0
  Network[2]  = 10.160.16.0
  Network[3]  = 10.160.32.0
  Network[4]  = 10.160.48.0
  Network[5]  = 10.160.64.0
  Network[6]  = 10.160.80.0
  Network[7]  = 10.160.96.0
  Network[8]  = 10.160.112.0
  Network[9]  = 10.160.128.0
  Network[10] = 10.160.144.0
  Network[11] = 10.160.160.0
  Network[12] = 10.160.176.0
  Network[13] = 10.160.192.0
  Network[14] = 10.160.208.0
  Network[15] = 10.160.224.0
  Network[16] = 10.160.240.0
```

Since we want 3 public and 3 private subnets, we'd call `cidrsubnet("10.160.0.0/16", 4, netnum)` 3 times each for both the public and private sides with `netnum` equal to 0, 1, and 2.  But since `terraform` doesn't have a real looping construct, or any means of iterating over a list, we either have to get clever, or hardcode values and call `cidrsubnet()` a total of 6 times.  In this case, it's easier to get clever.  In both the `public-nets.tf` and the `private-nets.tf` files we use the following construct:

```
resource "aws_subnet" "public" {
   vpc_id                  = "${aws_vpc.vpc.id}"
   count                   = "${var.pub_count}"
   cidr_block              = "${cidrsubnet(var.vpc_cidr, 4, count.index + var.pub_offset)}"
}
```

By setting `count` equal to the number of public subnets we wish to create, `terraform` will create that number of `"aws_subnet.public"` resources. Essentially, `terraform` iterates over this construct in a loop setting the magic variable `count.index` to each integer between 1 and the value of `count`. In this case, `count` is set to 3. And, above, we set our `pub_offset` variable to 0. So `terraform makes the following calls to `cidrsubnet()`:

```
  cidrsubnet("10.160.0.0/16", 4, 1 + 0)
  cidrsubnet("10.160.0.0/16", 4, 2 + 0)
  cidrsubnet("10.160.0.0/16", 4, 3 + 0)
```

This results in the assignment of:
```
  Network[1]  = 10.160.0.0
  Network[2]  = 10.160.16.0
  Network[3]  = 10.160.32.0
```

We do the same for the private subnets, but with an offset of 8 instead. That results in the following calls:

```
 cidrsubnet("10.160.0.0/16", 4, 1 + 8)
 cidrsubnet("10.160.0.0/16", 4, 2 + 8)
 cidrsubnet("10.160.0.0/16", 4, 3 + 8)
```

Which results in the following subnet assignments:

```
  Network[9]  = 10.160.128.0
  Network[10] = 10.160.144.0
  Network[11] = 10.160.160.0
```

Pretty neat. We can now create a VPC with any size CIDR block and carve out any number of subnets with the public and private nets spaced any distance apart we wish!
