# Terraform 용어 및 사용 방법 정리

...(생략된 기존 내용)...

---

## ✅ 실무 예제 기반 시나리오 및 모범 사례 (Best Practices)

Terraform은 단순한 IaC 도구를 넘어서, **구성 관리, 보안, 협업**을 함께 고려해야 하는 도구입니다. 아래는 실제 상황에서 자주 쓰이는 시나리오, 추천되는 모범 사례와 함께 관련 디렉토리 구조 및 예시 파일을 함께 제공합니다.

### 📌 VPC와 서브넷을 환경별로 분리하고 재사용하기

**시나리오**: dev/prod 환경을 분리해서 각기 다른 VPC와 서브넷을 관리해야 함

**디렉토리 구조 예시**:
```bash
infra/
├── modules/
│   └── network/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── dev/
│   ├── main.tf
│   └── dev.tfvars
└── prod/
    ├── main.tf
    └── prod.tfvars
```

**modules/network/main.tf**
```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.name
  }
}
```

**modules/network/variables.tf**
```hcl
variable "name" {
  type        = string
  description = "VPC 이름"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR 블록"
}
```

**modules/network/outputs.tf**
```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}
```

**dev/main.tf**
```hcl
module "network" {
  source    = "../modules/network"
  name      = "dev-vpc"
  vpc_cidr  = "10.0.0.0/16"
}
```

**dev/dev.tfvars**
```hcl
vpc_cidr = "10.0.0.0/16"
name     = "dev-vpc"
```

```bash
terraform apply -var-file=dev.tfvars
```

---

### 📌 민감 정보 암호화 및 변수 분리

**시나리오**: DB 비밀번호나 API 키 같은 민감 정보 관리 필요

**모범 사례**:
- `sensitive = true` 설정으로 출력 시 가림
- `.tfvars`에는 직접 노출하지 않고 환경 변수 `TF_VAR_XXX`로 주입
- 상태 파일을 S3에 저장하고 `encrypt = true`와 `DynamoDB Locking`으로 보호

**variables.tf**
```hcl
variable "db_password" {
  type        = string
  sensitive   = true
  description = "RDS 비밀번호"
}
```

```bash
# 실행 시 환경 변수 주입
export TF_VAR_db_password="MySecretPass"
```

---

### 📌 외부 템플릿(user_data)으로 인스턴스 구성 자동화

**시나리오**: EC2 user_data를 상황에 맞게 커스터마이징해야 함

**디렉토리 예시**:
```bash
infra/
├── templates/
│   └── user_data.tpl
└── prod/
    ├── main.tf
    └── prod.tfvars
```

**templates/user_data.tpl**
```bash
#!/bin/bash
hostnamectl set-hostname ${hostname}
echo "Hello from ${hostname}" > /var/www/html/index.html
```

**prod/main.tf**
```hcl
module "network" {
  source    = "../modules/network"
  name      = "prod-vpc"
  vpc_cidr  = "10.1.0.0/16"
}

resource "aws_instance" "app" {
  ami           = "ami-123456"
  instance_type = "t3.micro"

  user_data = templatefile("../templates/user_data.tpl", {
    hostname = "prod-app01"
  })
}
```

**prod/prod.tfvars**
```hcl
vpc_cidr = "10.1.0.0/16"
name     = "prod-vpc"
```

---

### 📌 변경된 리소스만 반영 (GitOps 스타일)

**시나리오**: 수백 개 스택 중 변경된 디렉토리만 적용하고 싶음

**디렉토리 구조 예시 (Terramate 기준)**:
```bash
infra/
├── terramate.hcl
├── stacks/
│   ├── dev/
│   │   └── main.tf
│   └── prod/
│       └── main.tf
```

**명령어 예시**:
```bash
terramate list --changed
terramate run --changed terraform apply
```

---

### 📌 상태 파일 관리 구조 (S3 + DynamoDB)

**backend 설정 예시**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-company-tfstate"
    key            = "envs/dev/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}
```

- 모든 환경마다 `key` 값은 디렉토리 기반으로 분리해 충돌 방지
- `encrypt`와 `dynamodb_table`로 안전한 협업 보장

---

이 섹션은 실무에서 발생하는 상황에 대한 **구체적 해결 전략과 디렉토리 구조, 실제 파일 템플릿**을 함께 제공합니다. 이 구조를 기반으로 실습하거나 팀 내 표준으로 정리하여 협업과 자동화 품질을 크게 향상시킬 수 있습니다.

