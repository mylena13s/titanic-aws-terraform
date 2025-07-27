# 🌊 Case Titanic com AWS e Terraform 🌊


## 📜 Sobre o projeto:

Função AWS Lambda construída em Python que prevê a probabilidade de sobrevivência de passageiros do Titanic, exposta via API RESTful provisionada com Terraform.

Funcionalidades: 

- Deploy serverless com AWS Lambda, API Gateway e DynamoDB.

- Infraestrutura como código (IaC) com Terraform

- Contrato da API documentado em OpenAPI 3.0 

- Respostas em JSON com o ID do passageiro e sua probabilidade de sobrevivência salva no DynamoDB.

## 🌟 Pré-requisitos

- Conta AWS, CLI configurado com permissões IAM de adminstrador para Lambda + API Gateway.
- Terraform (https://developer.hashicorp.com/terraform/downloads)

## 💻 Instalação

>  ⚠️ Certifique-se de ter a AWS CLI instalada e configurada com suas credenciais!


1. Clone o repositório:
```bash
git clone https://github.com/mylena13s/titanic-aws-case.git
```
2. Configure a AWS CLI:
```bash
aws configure
```
3.  Configure o ID da conta dentro da URI dentro do arquivo api.yaml
```bash
 uri: "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:<SEUUSERIDAQUI>:function:python_terraform_lambda/invocations"
```
4.  Inicie o Terraform
```bash
cd terraform
terraform init
```
5.  Aplique o Terraform para provisionar a infraestrutura
```bash
terraform apply
## confirme com yes para criar os recursos na AWS
```
6. Hora de testar 🧪
```markdown
Após o deploy, utilize o endpoint gerado para enviar requisições conforme o contrato OpenAPI (de preferência via Postman, pois o Swagger pode dar erro de CORS em requisições POST)
``` 
## 📌 Endpoints

| Método | Rota                     | Descrição                           |
|--------|--------------------------|-------------------------------------|
| POST   | `/sobreviventes`           | 	Escorar múltiplos passageiros       |
| DELETE   | `/sobreviventes/{id}`      | Remover passageiro avaliado pelo ID |
| GET    | `/sobreviventes/{id}` | Consultar escore de um passageiro específico      |
| GET    | `/sobreviventes` | 	Listar todos os passageiros avaliados   

## 📌 wefwefwefwef

| Método | Rota                     | body exemplo                           |
|--------|--------------------------|-------------------------------------|
| POST   | `/sobreviventes`           | {"PassengerId":101,"Pclass":1,"Sex":"female"}
| DELETE   | `/sobreviventes/{id}`      | /101 |
| GET    | `/sobreviventes/{id}` |    /101  |
| GET    | `/sobreviventes` | 	



