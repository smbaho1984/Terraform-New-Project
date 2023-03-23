module "network" {
    source = "./network" 
}

module "sg" {
    source = "./sg"
    vpc_id = module.network.vpc_main
    
}

module "ec2" {
    source = "./ec2"
    sg
}