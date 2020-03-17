# Oracle PoC

## Agenda
- Efetuar Data Pump e RMAN (não precisa ser com todos os dados, para a PoC vamos replicar o schema e uma parte dos dados)
- Instalar o AWS CLI
- Criar S3, VPC e Roles
- Criar RDS e EC2
- Efetuar replicação Data Pump para RDS & replicação RMAN para EC2
- Conectar via um client para verificar a base replicada


## Comandos auxiliares

### S3 MultiPart Upload

Ao fazer upload de arquivos grandes para o Amazon S3, é uma prática recomendada utilizar o multipart upload. Se você estiver usando a AWS Command Line Interface (AWS CLI), todos os comandos aws s3 de alto nível executam automaticamente um upload de várias partes quando o objeto é grande. Esses comandos de alto nível incluem aws s3 cp e aws s3 sync.

### S3 Transfer Acceleration

```
aws s3api put-bucket-accelerate-configuration --bucket poc-backup-bucket --accelerate-configuration Status=Enabled

aws configure set s3.addressing_style virtual

aws s3 cp file.txt s3://poc-backup-bucket/rman-test --region sa-east-1 --endpoint-url http://s3-accelerate.amazonaws.com
```

### SSH Tunnel

```
ssh -o ProxyCommand='ssh -i poc-kp.pem -W %h:%p  ec2-user@public-ip' -i poc-kp.pem ec2-user@private-ip
```

### Instalando Oracle DB EC2

_Obs.: AMI Oracle Linux - ami-5edf4132_

```
yum install wget zip unzip -y
yum install oracle-rdbms-server-12cR1-preinstall -y
sudo update -y
mkdir -p /u01/software
cd /u01/software
unzip linuxamd64_12102_database_1of2.zip
unzip linuxamd64_12102_database_2of2.zip
cd database
chown -R oracle.oinstall /u01
su - oracle
cd /u01/software/database
./runInstaller -silent -ignoreSysPrereqs -responseFile /tmp/oui12102.rsp
```

## Links auxiliares

- Instalar AWS CLI: https://docs.aws.amazon.com/pt_br/cli/latest/userguide/install-cliv2.html
- Considerações para migração Oracle: https://d1.awsstatic.com/whitepapers/strategies-for-migrating-oracle-database-to-aws.pdf
- RDS S3 DataPump: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/oracle-s3-integration.html#oracle-s3-integration.using.download
- Migração Oracle DataPump: https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/migrate-an-on-premises-oracle-database-to-amazon-rds-for-oracle-using-oracle-data-pump.html
- Oracle EC2: https://oracle-base.com/articles/vm/aws-ec2-installation-of-oracle
- Oracle 11gR2: https://oracle-base.com/articles/11g/oracle-db-11gr2-installation-on-oracle-linux-6
- Oracle 11gR2 tips: https://www.tothenew.com/blog/installing-oracle-11g-on-cloud-ec2-instance-rhelcentos-6-x-through-command-line/
- Backup RMAN S3: https://aws.amazon.com/backup-recovery/gsg-oracle-rman/
- DataPump & RMAN S3 integration: https://aws.amazon.com/pt/about-aws/whats-new/2019/02/Amazon-RDS-for-Oracle-Now-Supports-Amazon-S3-Integration/
- QuickStart: https://aws-quickstart.s3.amazonaws.com/quickstart-oracle-database/doc/oracle-database-on-the-aws-cloud.pdf
- Licensing: https://docs.aws.amazon.com/whitepapers/latest/oracle-database-aws-best-practices/oracle-licensing-considerations.html
