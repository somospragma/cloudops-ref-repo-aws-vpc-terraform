# Ejemplo: VPC con NAT Gateway Regional

Este ejemplo demuestra cómo usar el módulo VPC con **NAT Gateway Regional**, la nueva funcionalidad de AWS que simplifica la arquitectura de red.

## Características

- ✅ **Un solo NAT Gateway** para toda la VPC
- ✅ **No requiere subnets públicas** para el NAT Gateway
- ✅ **Alta disponibilidad automática** - se expande a nuevas AZs automáticamente
- ✅ **Modo automático** - AWS gestiona las IPs automáticamente
- ✅ **Mayor capacidad** - hasta 32 IPs por AZ

## Arquitectura

```
VPC (10.0.0.0/16)
│
├── Regional NAT Gateway (standalone)
│   └── Expande automáticamente a AZs con workloads
│
├── Private Subnets (3 AZs)
│   ├── 10.0.1.0/24 (us-east-1a)
│   ├── 10.0.2.0/24 (us-east-1b)
│   └── 10.0.3.0/24 (us-east-1c)
│   └── Todas apuntan al mismo NAT Gateway ID
│
└── Database Subnets (3 AZs)
    ├── 10.0.11.0/24 (us-east-1a)
    ├── 10.0.12.0/24 (us-east-1b)
    └── 10.0.13.0/24 (us-east-1c)
    └── Sin acceso a Internet
```

## Diferencias con NAT Gateway Zonal

| Característica | Zonal (Tradicional) | Regional (Nuevo) |
|----------------|---------------------|------------------|
| NAT Gateways | Uno por AZ | Uno para toda la VPC |
| Subnets públicas | Requeridas | No requeridas |
| Alta disponibilidad | Manual (crear por AZ) | Automática |
| IPs por AZ | 8 máximo | 32 máximo |
| Configuración | Compleja | Simple |
| Costo | Mayor (múltiples NAT) | Menor (un NAT) |

## Uso

### 1. Configurar variables

Copia el archivo de ejemplo:
```bash
cp terraform.tfvars.sample terraform.tfvars
```

Edita `terraform.tfvars` con tus valores:
```hcl
profile     = "tu-perfil-aws"
aws_region  = "us-east-1"
client      = "tu-cliente"
project     = "tu-proyecto"
environment = "dev"

# Regional NAT Gateway
nat_mode          = "regional"
nat_regional_mode = "auto"
```

### 2. Inicializar Terraform

```bash
terraform init
```

### 3. Planificar

```bash
terraform plan
```

### 4. Aplicar

```bash
terraform apply
```

## Recursos Creados

- 1 VPC
- 6 Subnets (3 private + 3 database)
- 1 Internet Gateway
- **1 Regional NAT Gateway** (se expande automáticamente a las 3 AZs)
- 2 Route Tables (private + database)
- VPC Flow Logs
- IAM Role y Policy para Flow Logs

## Outputs

```hcl
vpc_id                              = "vpc-xxxxx"
nat_gateway_id                      = "nat-xxxxx"
nat_gateway_mode                    = "regional"
regional_nat_gateway_route_table_id = "rtb-xxxxx"
subnet_ids = {
  "private-0" = "subnet-xxxxx"
  "private-1" = "subnet-yyyyy"
  "private-2" = "subnet-zzzzz"
  ...
}
```

## Costos Estimados

Para ambiente de desarrollo en us-east-1:

| Recurso | Costo Mensual |
|---------|---------------|
| VPC | Gratis |
| Subnets | Gratis |
| Internet Gateway | Gratis |
| **Regional NAT Gateway** | **~$32/mes** |
| Flow Logs | ~$0.50/GB |

**Total estimado**: ~$35-40/mes

💡 **Ahorro**: Con NAT Gateway Zonal necesitarías 3 NAT Gateways (~$96/mes)

## Modo Manual (Opcional)

Si prefieres controlar las IPs manualmente:

```hcl
nat_mode          = "regional"
nat_regional_mode = "manual"

nat_regional_az_config = [
  {
    availability_zone = "us-east-1a"
    allocation_ids    = ["eipalloc-xxxxx"]
  },
  {
    availability_zone = "us-east-1b"
    allocation_ids    = ["eipalloc-yyyyy"]
  }
]
```

**Nota**: Debes crear los EIPs previamente.

## Limpieza

```bash
terraform destroy
```

## Referencias

- [AWS Regional NAT Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateways-regional.html)
- [Terraform aws_nat_gateway Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)
