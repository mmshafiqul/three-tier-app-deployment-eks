module "vpc" {
  source                 = "./modules/vpc"
  ipv4_cidr_block        = var.ipv4_cidr_block
  ipv6_cidr_block_enabled = var.ipv6_cidr_block_enabled
  enable_dns_support     = var.enable_dns_support
  enable_dns_hostnames   = var.enable_dns_hostnames
  tags                   = var.tags
}

module "subnet" {
  source                     = "./modules/subnet"
  vpc_id                     = module.vpc.vpc_id
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  availability_zones         = var.availability_zones
  tags                       = var.tags

  depends_on = [module.vpc]
}

module "igw" {
  source = "./modules/igw"
  vpc_id = module.vpc.vpc_id
  tags   = var.tags
  
  depends_on = [module.vpc]
}

module "route_table" {
  source               = "./modules/route-table"
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.subnet.public_subnet_ids
  private_subnet_ids   = module.subnet.private_subnet_ids
  gateway_id           = module.igw.internet_gateway_id
  tags                 = var.tags
  
  depends_on = [module.vpc, module.subnet, module.igw]
}

module "key" {
  source     = "./modules/key"
  key_name   = var.key_name
  algorithm  = var.algorithm
  rsa_bits   = var.rsa_bits
}

module "bastion" {
  source          = "./modules/bastion-ec2"
  vpc_id          = module.vpc.vpc_id
  public_subnet_id = module.subnet.public_subnet_ids[0]
  instance_type   = var.instance_type
  ami_id          = var.ami_id
  key_name        = module.key.key_name
  tags            = var.tags

  depends_on = [module.vpc, module.subnet, module.route_table, module.key]
}

module "eks" {
  source              = "./modules/eks"
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.subnet.public_subnet_ids
  kubernetes_version  = var.kubernetes_version
  node_instance_type  = var.node_instance_type
  desired_size        = var.desired_size
  max_size            = var.max_size
  min_size            = var.min_size
  tags                = var.tags

  depends_on = [module.vpc, module.subnet]
}