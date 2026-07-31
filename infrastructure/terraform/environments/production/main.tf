# Production Environment

terraform {
  backend "s3" {
    bucket         = "jenkins-tf-state"
    key            = "jenkins-cloud-native-app/production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

module "app" {
  source = "../../"

  environment     = "production"
  aws_region      = "us-east-1"
  vpc_cidr        = "10.0.0.0/16"
  az_count        = 3
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  cluster_version = "1.27"

  node_groups = {
    general = {
      instance_types = ["m5.large"]
      min_size       = 3
      max_size       = 10
      desired_size   = 3
      labels = {
        role = "general"
      }
      taints = []
    }
    performance = {
      instance_types = ["c5.large"]
      min_size       = 1
      max_size       = 5
      desired_size   = 1
      labels = {
        role = "performance"
      }
      taints = [
        {
          key    = "dedicated"
          value  = "performance"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }

  db_engine_version = "15.3"
  db_instance_class = "db.r6g.large"
  db_storage_size   = 100
  db_name           = "appdb"
  db_user           = "appuser"
  db_password       = "productionPassword123!"
}