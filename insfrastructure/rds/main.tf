provider "aws" {
    profile = var.profile
    region = "us-east-1"
}

resource "aws_db_instance" "default" {
    allocated_storage = 20
    storage_type = "gp2"
    engine = "postgres"
    instance_class = "db.t3.micro"
    db_name = "contacts_db"
    username = "postgres"
    password = var.password
    identifier = var.id
    # pc_security_group_ids = [ "vpc-0aea46b717f801cc7" ]
    publicly_accessible = true
}