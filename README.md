## Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"


Зачастую разбираться в новых инструментах гораздо интересней понимая то, как они работают изнутри. Поэтому в рамках первого необязательного задания предлагается завести свою учетную запись в AWS (Amazon Web Services).

### Задача 1. Регистрация в aws и знакомство с основами (необязательно, но крайне желательно).

Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием терраформа и aws.

1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя, а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано здесь.
2. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше.



***Ответ:***


![alt](https://i.ibb.co/JkXyhgD/Screenshot-01.jpg)

---

### Задача 2. Инициализируем проект и создаем воркспейсы.


1. Выполните `terraform init`:

* если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице `dynamodb`.
* иначе будет создан локальный файл со стейтами.

2. Создайте два воркспейса `stage` и `prod`.
3. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах использовались разные `instance_type`.
4. Добавим `count`. Для `stage` должен создаться один экземпляр ec2, а для `prod` два.
5. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
6. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
7. При желании поэкспериментируйте с другими параметрами и рессурсами.

В виде результата работы пришлите:

* Вывод команды terraform workspace list.
* Вывод команды terraform plan для воркспейса prod.



***Ответ:***

>Выполните `terraform init`

![alt](https://i.ibb.co/GnnG4vK/Screenshot-1.jpg)

>Создайте два воркспейса stage и prod.
>
```
terraform workspace new stage
terraform workspace new prod
terraform workspace list
```

![alt](https://i.ibb.co/cCxdJmP/Screenshot-2.jpg)


Файл `s3.tf`

```
provider "aws" {
                region = "us-west-2"
        }
        resource "aws_s3_bucket" "bucket" {
          bucket = "netology-bucket-${terraform.workspace}"
          acl    = "private"
          tags = {
            Name        = "Bucket1"
            Environment = terraform.workspace
          }
        }
```

terraform plan для `prod`

```
terraform plan
```
![alt](https://i.ibb.co/yngvkny/Screenshot-3.jpg)

```
terraform apply
```
![alt](https://i.ibb.co/PjZN5SX/Screenshot-4.jpg)

Проверяем в " Amazon S3":

![alt](https://i.ibb.co/gd6BfWQ/Screenshot-5.jpg)

---
Изменим файл `s3.tf`
Для stage должен создаться один экземпляр ec2, а для prod два

```
provider "aws" {
        region = "us-west-2"
}

locals {
  web_instance_count_map = {
  stage = 1
  prod = 2
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "netology-bucket-${count.index}-${terraform.workspace}"
  acl    = "private"
  tags = {
    Name        = "Bucket ${count.index}"
    Environment = terraform.workspace
  }
  count = local.web_instance_count_map[terraform.workspace]
}

```
teeraform plan для `prod` - получился очень большой
```
romrsch@ubuntu:~/7.3$ terraform plan
aws_s3_bucket.bucket[0]: Refreshing state... [id=netology-bucket-prod]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # aws_s3_bucket.bucket has been deleted
  - resource "aws_s3_bucket" "bucket" {
      - acl                         = "private" -> null
      - arn                         = "arn:aws:s3:::netology-bucket-prod" -> null
      - bucket                      = "netology-bucket-prod" -> null
      - bucket_domain_name          = "netology-bucket-prod.s3.amazonaws.com" -> null
      - bucket_regional_domain_name = "netology-bucket-prod.s3.us-west-2.amazonaws.com" -> null
      - force_destroy               = false -> null
      - hosted_zone_id              = "Z3BJ6K6RIION7M" -> null
      - id                          = "netology-bucket-prod" -> null
      - region                      = "us-west-2" -> null
      - request_payer               = "BucketOwner" -> null
      - tags                        = {
          - "Environment" = "prod"
          - "Name"        = "Bucket1"
        } -> null
      - tags_all                    = {
          - "Environment" = "prod"
          - "Name"        = "Bucket1"
        } -> null

      - versioning {
          - enabled    = false -> null
          - mfa_delete = false -> null
        }
    }

Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using ignore_changes, the following plan may include actions to undo or respond to these changes.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_s3_bucket.bucket[0] must be replaced
-/+ resource "aws_s3_bucket" "bucket" {
      + acceleration_status         = (known after apply)
      ~ arn                         = "arn:aws:s3:::netology-bucket-prod" -> (known after apply)
      ~ bucket                      = "netology-bucket-prod" -> "netology-bucket-0-prod" # forces replacement
      ~ bucket_domain_name          = "netology-bucket-prod.s3.amazonaws.com" -> (known after apply)
      ~ bucket_regional_domain_name = "netology-bucket-prod.s3.us-west-2.amazonaws.com" -> (known after apply)
      ~ hosted_zone_id              = "Z3BJ6K6RIION7M" -> (known after apply)
      ~ id                          = "netology-bucket-prod" -> (known after apply)
      ~ region                      = "us-west-2" -> (known after apply)
      ~ request_payer               = "BucketOwner" -> (known after apply)
      ~ tags                        = {
          ~ "Name"        = "Bucket1" -> "Bucket 0"
            # (1 unchanged element hidden)
        }
      ~ tags_all                    = {
          ~ "Name"        = "Bucket1" -> "Bucket 0"
            # (1 unchanged element hidden)
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)
        # (2 unchanged attributes hidden)

      ~ versioning {
          ~ enabled    = false -> (known after apply)
          ~ mfa_delete = false -> (known after apply)
        }
    }

  # aws_s3_bucket.bucket[1] will be created
  + resource "aws_s3_bucket" "bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "netology-bucket-1-prod"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Environment" = "prod"
          + "Name"        = "Bucket 1"
        }
      + tags_all                    = {
          + "Environment" = "prod"
          + "Name"        = "Bucket 1"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }
    }

Plan: 2 to add, 0 to change, 1 to destroy.

```
```
romrsch@ubuntu:~/7.3$ terraform workspace show
prod

terraform apply
```
![alt](https://i.ibb.co/Phydc4t/Screenshot-6.jpg)

Проверяем в " Amazon S3":

![alt](https://i.ibb.co/Xkz41y7/Screenshot-7.jpg)

Переключимся в Workspace "stage" 

![alt](https://i.ibb.co/kDZ6mkF/Screenshot-8.jpg)

terraform plan для `stage`
```
terraform plan
```
![alt](https://i.ibb.co/K9x51gV/Screenshot-9.jpg)

```
terraform apply
```
![alt](https://i.ibb.co/K75qYr4/Screenshot-10.jpg)

Проверяем в " Amazon S3":

![alt](https://i.ibb.co/G3y0Vnw/Screenshot-11.jpg)

---

Файл `s3.tf`
```
provider "aws" {
        region = "us-west-2"
}

locals {
  web_instance_count_map = {
  stage = 1
  prod = 2
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "netology-bucket-${count.index}-${terraform.workspace}"
  acl    = "private"
  tags = {
    Name        = "Bucket ${count.index}"
    Environment = terraform.workspace
  }
  count = local.web_instance_count_map[terraform.workspace]
}

locals {
  backets_ids = toset([
    "e1",
    "e2",
  ])
}
resource "aws_s3_bucket" "bucket_e" {
  for_each = local.backets_ids
  bucket = "netology-bucket-${each.key}-${terraform.workspace}"
  acl    = "private"
  tags = {
    Name        = "Bucket ${each.key}"
    Environment = terraform.workspace
  }
}

```
Переключаемся в workspace `prod`, 
```
terraform workspace select prod
terraform plan
terraform  apply
```
![alt](https://i.ibb.co/BB1C4m7/Screenshot-12.jpg)

FOR_EACH

Результат " Amazon S3":

![alt](https://i.ibb.co/nLTdDjD/Screenshot-13.jpg)







