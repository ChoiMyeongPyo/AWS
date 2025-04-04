# Terraform 용어 및 사용 방법 정리

## 📦 기본 구조 관련 용어 및 예시

### provider
Terraform이 어떤 클라우드 플랫폼과 상호작용할지를 정의
```hcl
provider "aws" {
  region  = var.region
  profile = "default"
}
```

### resource
실제 생성할 인프라를 정의하는 블록
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"
  tags = {
    Name = "MyWebServer"
  }
}
```

### data
이미 존재하는 리소스를 조회하여 사용
```hcl
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t3.micro"
}
```

### variable
사용자 입력값을 변수로 받아 코드 재사용성 향상
```hcl
variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}
```

### output
Terraform 실행 결과에서 사용자가 확인하고 싶은 값을 출력
```hcl
output "instance_id" {
  description = "웹 서버 인스턴스 ID"
  value       = aws_instance.web.id
}
```

### module
재사용 가능한 코드 블록을 별도 모듈로 분리
```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
}
```

### locals
복잡한 계산이나 반복을 피하기 위한 지역 변수
```hcl
locals {
  common_tags = {
    Environment = "dev"
    Owner       = "team-dev"
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  tags   = local.common_tags
}
```

### terraform block
Terraform 자체의 설정을 정의
```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "env/dev/terraform.tfstate"
    region = "ap-northeast-2"
  }
}
```

---

## ⚙️ 실행 관련 명령어 예시

### terraform init
프로젝트 초기화 및 provider 설치
```bash
terraform init
```

### terraform plan
변경사항 미리 보기
```bash
terraform plan -out=tfplan
```

### terraform apply
리소스 생성 또는 변경
```bash
terraform apply tfplan
```

### terraform destroy
모든 리소스 삭제
```bash
terraform destroy
```

### terraform validate
코드 문법 오류 확인
```bash
terraform validate
```

### terraform refresh
현재 인프라 상태와 상태 파일 동기화
```bash
terraform refresh
```

### terraform output
출력 값 확인
```bash
terraform output
terraform output instance_id
```

---

## 📁 파일 및 구성 요소

| 파일 이름 | 설명 |
|------------|------|
| `main.tf` | 주요 리소스를 정의하는 파일 |
| `variables.tf` | 변수들을 정의하는 파일 |
| `terraform.tfvars` | 변수에 실제 값을 할당하는 파일 |
| `outputs.tf` | 결과 출력 정의 파일 |
| `provider.tf` | provider 설정을 모아놓는 파일 |
| `.terraform.lock.hcl` | provider 버전 잠금 파일 |
| `terraform.tfstate` | 현재 인프라 상태를 기록하는 파일 (자동 생성) |

---

## 🔐 보안 관련 예시

### sensitive output
민감한 정보는 출력에서 가림
```hcl
output "db_password" {
  value     = var.db_password
  sensitive = true
}
```

CLI에서 확인 시:
```bash
db_password = (sensitive value)
```

### lifecycle
파괴 방지 설정
```hcl
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-secure-bucket"

  lifecycle {
    prevent_destroy = true
  }
}
```

---

## 🧠 반복 및 조건 관련 예시

### count 예시
```hcl
resource "aws_instance" "web" {
  count         = 3
  ami           = var.ami_id
  instance_type = "t3.micro"
  tags = {
    Name = "web-${count.index}"
  }
}
```

### for_each 예시
```hcl
variable "buckets" {
  type = map(string)
  default = {
    logs   = "log-bucket"
    assets = "asset-bucket"
  }
}

resource "aws_s3_bucket" "named" {
  for_each = var.buckets
  bucket   = each.value
  tags = {
    Name = each.key
  }
}
```

### depends_on 예시
```hcl
resource "aws_iam_role" "lambda_exec" {
  # IAM role 생성
}

resource "aws_lambda_function" "my_lambda" {
  # Lambda 정의
  depends_on = [aws_iam_role.lambda_exec]
}
```

---
# Terraform 용어 및 사용 방법 정리

...(생략된 기존 내용)...

---

## 🚀 고급 기능 설명

...(이전 고급 기능 내용 유지)...

---

## 🧠 추가 고급 기능 및 기법

### 🧩 meta-arguments
모든 리소스에서 공통으로 사용할 수 있는 메타 인자들:

#### `depends_on`
명시적으로 리소스 간 의존성을 설정
```hcl
resource "aws_iam_role" "lambda_role" { ... }

resource "aws_lambda_function" "my_lambda" {
  function_name = "my-func"
  ...
  depends_on = [aws_iam_role.lambda_role]
}
```

#### `count`
지정된 수만큼 리소스를 반복 생성
```hcl
resource "aws_instance" "web" {
  count         = 3
  ami           = var.ami_id
  instance_type = "t3.micro"
  tags = {
    Name = "web-${count.index}"
  }
}
```

#### `for_each`
맵 또는 셋을 기반으로 반복 생성 (이전 예시 참고)

---

### 🧮 Terraform 내장 함수 (Functions)
Terraform에는 문자열, 리스트, 맵, 논리 처리 등을 위한 다양한 내장 함수가 존재

#### 문자열 함수 예시
```hcl
locals {
  bucket_name = lower("My-Bucket-Prod")
  prefixed    = join("-", [var.env, var.name])
}
```

#### 리스트/맵 함수 예시
```hcl
locals {
  unique_zones = distinct(["a", "a", "b"])
  merged_map = merge({a = 1}, {b = 2})
}
```

전체 함수 목록은 [공식 함수 목록](https://developer.hashicorp.com/terraform/language/functions) 참조

---

### 🔀 조건문과 삼항 연산자
```hcl
resource "aws_instance" "example" {
  instance_type = var.is_prod ? "t3.large" : "t3.micro"
}
```

---

### 📄 templatefile 함수
외부 템플릿 파일을 렌더링하여 변수 치환 가능

#### user_data.tpl
```bash
#!/bin/bash
hostnamectl set-hostname ${hostname}
```

#### main.tf
```hcl
resource "aws_instance" "with_userdata" {
  user_data = templatefile("user_data.tpl", {
    hostname = "web01"
  })
}
```

---

### ✅ precondition / postcondition (Terraform 1.2+)
리소스 생성 전/후 조건을 검사할 수 있음
```hcl
resource "aws_instance" "check" {
  ami           = var.ami_id
  instance_type = var.instance_type

  lifecycle {
    precondition {
      condition     = contains(["t3.micro", "t3.small"], var.instance_type)
      error_message = "허용된 인스턴스 타입이 아닙니다."
    }
  }
}
```

---

## 📘 참고
- [Terraform 공식 문서](https://developer.hashicorp.com/terraform/docs)
- [Terraform Functions](https://developer.hashicorp.com/terraform/language/functions)
- [Meta-Arguments](https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on)
- [Expressions & Conditionals](https://developer.hashicorp.com/terraform/language/expressions/conditionals)
- [templatefile 문서](https://developer.hashicorp.com/terraform/language/functions/templatefile)
- [Pre/Post Condition 문서](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#precondition-and-postcondition)

---

이 문서는 Terraform 주요 용어들과 실무에서 자주 사용하는 패턴, 고급 기법까지 예제를 중심으로 정리한 문서입니다. 프로젝트 요구사항에 맞게 구조화하여 사용하는 데 도움이 될 것입니다.

