# Permisos IAM Requeridos - Módulo VPC

Este documento detalla los permisos IAM necesarios para desplegar y gestionar el módulo VPC.

## 📋 Resumen de Permisos

Para desplegar este módulo VPC, el usuario/rol de IAM necesita permisos para:

1. **VPC y Networking** - Crear y gestionar VPC, subnets, route tables
2. **Internet Gateway** - Crear y adjuntar IGW
3. **NAT Gateway** - Crear NAT Gateway (zonal o regional) y Elastic IPs
4. **VPC Flow Logs** - Crear Flow Logs y log groups en CloudWatch
5. **IAM** - Crear rol de servicio para Flow Logs
6. **Tags** - Gestionar etiquetas en recursos

## 🔐 Política IAM Mínima

Usa la política personalizada en: [`vpc-deployment-policy.json`](./vpc-deployment-policy.json)

**Aplicar la política:**
```bash
# Crear la política
aws iam create-policy \
  --policy-name VPCModuleDeploymentPolicy \
  --policy-document file://iam-permissions/vpc-deployment-policy.json

# Adjuntar a un usuario
aws iam attach-user-policy \
  --user-name tu-usuario \
  --policy-arn arn:aws:iam::ACCOUNT-ID:policy/VPCModuleDeploymentPolicy
```

## 📝 Permisos Detallados

### VPC Management
```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:CreateVpc",
    "ec2:DeleteVpc",
    "ec2:DescribeVpcs",
    "ec2:ModifyVpcAttribute",
    "ec2:DescribeVpcAttribute"
  ],
  "Resource": "*"
}
```

### Subnet Management
```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:CreateSubnet",
    "ec2:DeleteSubnet",
    "ec2:DescribeSubnets",
    "ec2:ModifySubnetAttribute"
  ],
  "Resource": "*"
}
```

### Internet Gateway
```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:CreateInternetGateway",
    "ec2:DeleteInternetGateway",
    "ec2:AttachInternetGateway",
    "ec2:DetachInternetGateway",
    "ec2:DescribeInternetGateways"
  ],
  "Resource": "*"
}
```

### NAT Gateway (Regional y Zonal)
```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:CreateNatGateway",
    "ec2:DeleteNatGateway",
    "ec2:DescribeNatGateways",
    "ec2:AllocateAddress",
    "ec2:ReleaseAddress",
    "ec2:DescribeAddresses"
  ],
  "Resource": "*"
}
```

### Route Tables
```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:CreateRouteTable",
    "ec2:DeleteRouteTable",
    "ec2:DescribeRouteTables",
    "ec2:CreateRoute",
    "ec2:DeleteRoute",
    "ec2:AssociateRouteTable",
    "ec2:DisassociateRouteTable"
  ],
  "Resource": "*"
}
```

### VPC Flow Logs
```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:CreateFlowLogs",
    "ec2:DeleteFlowLogs",
    "ec2:DescribeFlowLogs",
    "logs:CreateLogGroup",
    "logs:DeleteLogGroup",
    "logs:DescribeLogGroups",
    "logs:PutRetentionPolicy"
  ],
  "Resource": "*"
}
```

### IAM for Flow Logs Role
```json
{
  "Effect": "Allow",
  "Action": [
    "iam:CreateRole",
    "iam:DeleteRole",
    "iam:GetRole",
    "iam:PutRolePolicy",
    "iam:DeleteRolePolicy",
    "iam:AttachRolePolicy",
    "iam:DetachRolePolicy",
    "iam:PassRole"
  ],
  "Resource": "arn:aws:iam::*:role/*-vpc-flow-logs-role"
}
```

## 🎯 Recursos Creados por el Módulo

Este módulo crea los siguientes recursos:

- ✅ 1 VPC
- ✅ N Subnets (según configuración)
- ✅ 1 Internet Gateway (opcional)
- ✅ 1 NAT Gateway Regional o N NAT Gateways Zonales (opcional)
- ✅ N Elastic IPs (para NAT Gateways zonales)
- ✅ N Route Tables
- ✅ 1 VPC Flow Log
- ✅ 1 CloudWatch Log Group
- ✅ 1 IAM Role (para Flow Logs)

## 💰 Costos Asociados

- **VPC, Subnets, Route Tables**: Sin costo
- **Internet Gateway**: Sin costo
- **NAT Gateway Regional**: ~$32/mes + data transfer
- **NAT Gateway Zonal**: ~$32/mes por AZ + data transfer
- **VPC Flow Logs**: Según volumen de logs
- **CloudWatch Logs**: Según retención y volumen

## 🔒 Mejores Prácticas

### 1. Usar Roles en lugar de Usuarios
```bash
aws iam create-role \
  --role-name TerraformVPCRole \
  --assume-role-policy-document file://trust-policy.json
```

### 2. Limitar por Region
```json
{
  "Condition": {
    "StringEquals": {
      "aws:RequestedRegion": "us-east-1"
    }
  }
}
```

### 3. Limitar por Tags
```json
{
  "Condition": {
    "StringEquals": {
      "ec2:ResourceTag/ManagedBy": "Terraform"
    }
  }
}
```

## 🆘 Troubleshooting

### Error: "User is not authorized to perform: ec2:CreateVpc"
**Solución**: Adjuntar la política VPCModuleDeploymentPolicy

### Error: "User is not authorized to perform: iam:PassRole"
**Solución**: Agregar permiso `iam:PassRole` para el rol de Flow Logs

### Error: "Access Denied" al crear NAT Gateway
**Solución**: Verificar permisos `ec2:CreateNatGateway` y `ec2:AllocateAddress`

## 📚 Referencias

- [AWS VPC IAM Permissions](https://docs.aws.amazon.com/vpc/latest/userguide/security-iam.html)
- [NAT Gateway Permissions](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
- [VPC Flow Logs Permissions](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-cwl.html)
