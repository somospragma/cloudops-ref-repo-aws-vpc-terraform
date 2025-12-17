# **Módulo Terraform: cloudops-ref-repo-aws-vpc-terraform**

## Descripción:

Este módulo facilita la creación de una Virtual Private Cloud (VPC) completa en AWS, proporcionando configuraciones de red, subredes, tablas de enrutamiento y gateways. Incluye la creación de subredes públicas y privadas, Internet Gateway (IGW), NAT Gateway, rutas personalizadas y VPC Flow Logs para una gestión eficiente y segura de la red.

Este módulo de Terraform para una VPC de AWS realizará las siguientes acciones:

- Crear una VPC con el CIDR block especificado.
- Crear subredes públicas y privadas según la configuración proporcionada.
- Configurar tablas de enrutamiento para cada subred.
- Crear un Internet Gateway (IGW) si se especifica.
- Crear un NAT Gateway si se especifica.
- Configurar rutas personalizadas según sea necesario.
- Configurar el grupo de seguridad predeterminado de la VPC.
- Implementar VPC Flow Logs para monitoreo y auditoría del tráfico de red (característica obligatoria).

Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Estructura del Módulo
El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-vpc-terraform/
└── sample/
    ├── vpc-regional/
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── providers.tf
    │   ├── terraform.tfvars
    │   └── variables.tf
├── .gitignore
├── CHANGELOG.md
├── data.tf
├── locals.tf          # Nomenclatura centralizada
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── variables.tf
```

- Los archivos principales del módulo (`data.tf`, `main.tf`, `outputs.tf`, `variables.tf`, `providers.tf`) se encuentran en el directorio raíz.
- `CHANGELOG.md` y `README.md` también están en el directorio raíz para fácil acceso.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.

## NAT Gateway: Zonal vs Regional

### Modo Zonal (Por defecto)
El comportamiento tradicional donde se crea un NAT Gateway por Availability Zone:
- ✅ Requiere subnets públicas para hospedar el NAT Gateway
- ✅ Un NAT Gateway por AZ para alta disponibilidad
- ✅ Cada subnet privada apunta a su NAT Gateway de la misma AZ
- ⚠️ Más costoso (múltiples NAT Gateways)
- ⚠️ Configuración manual de rutas por AZ

### Modo Regional (Nuevo)
Un único NAT Gateway que se expande automáticamente a todas las AZs:
- ✅ **No requiere subnets públicas** - el NAT es un recurso standalone
- ✅ **Un solo NAT Gateway ID** para toda la VPC
- ✅ **Alta disponibilidad automática** - se expande a nuevas AZs automáticamente
- ✅ **Mayor capacidad** - hasta 32 IPs por AZ (vs 8 en zonal)
- ✅ **Route table automática** - crea su propia route table con ruta al IGW
- ✅ **Más económico** - un solo NAT Gateway en lugar de múltiples
- ✅ **Simplificación** - todas las subnets privadas usan el mismo NAT Gateway ID

**Cuándo usar Regional:**
- ✅ Nuevos proyectos
- ✅ Arquitecturas que buscan simplicidad
- ✅ Optimización de costos
- ✅ Alta disponibilidad automática

**Cuándo usar Zonal:**
- ✅ Compatibilidad con infraestructura existente
- ✅ Casos de uso con NAT privado (private connectivity)
- ✅ Control granular por AZ

## Seguridad & Cumplimiento
 
Consulta a continuación la fecha y los resultados de nuestro escaneo de seguridad y cumplimiento.
 
<!-- BEGIN_BENCHMARK_TABLE -->
| Benchmark | Date | Version | Description | 
| --------- | ---- | ------- | ----------- | 
| ![checkov](https://img.shields.io/badge/checkov-passed-green) | 2023-09-20 | 3.2.232 | Escaneo profundo del plan de Terraform en busca de problemas de seguridad y cumplimiento |
<!-- END_BENCHMARK_TABLE -->

## Provider Configuration

Este módulo requiere la configuración de un provider específico para el proyecto. Debe configurarse de la siguiente manera:

```hcl
sample/vpc/providers.tf
provider "aws" {
  alias = "alias01"
  # ... otras configuraciones del provider
}

sample/vpc/main.tf
module "vpc" {
  source = ""
  providers = {
    aws.project = aws.alias01
  }
  # ... resto de la configuración
}
```

## Uso del Módulo:

### Ejemplo Básico (Modo Zonal - Comportamiento por defecto)

```hcl
module "vpc" {
  source = ""
  
  providers = {
    aws.project = aws.project
  }

  # Common configuration
  client        = "example"
  project       = "example"
  environment   = "dev"
  aws_region    = "us-east-1"

  # VPC configuration
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  #Subnet configuration
  subnet_config = {
    public = {
      public = true
      subnets = [
        {
          cidr_block        = "10.0.1.0/24"
          availability_zone = "us-east-1a"
        },
        {
          cidr_block        = "10.0.2.0/24"
          availability_zone = "us-east-1b"
        }
      ]
      custom_routes = []
    },
    private = {
      public = false
      include_nat = true
      subnets = [
        {
          cidr_block        = "10.0.3.0/24"
          availability_zone = "us-east-1a"
        },
        {
          cidr_block        = "10.0.4.0/24"
          availability_zone = "us-east-1b"
        }
      ]
      custom_routes = []
    }
  }

  # Gateway configuration
  create_igw = true
  create_nat = true
  nat_mode   = "zonal"  # Por defecto, compatible con versiones anteriores

  # VPC Flow Logs configuration (obligatorio)
  flow_log_retention_in_days = 30

  # Additional tags (opcional)
  additional_tags = {
    ManagedBy  = "Terraform"
    Team       = "CloudOps"
    CostCenter = "Engineering"
  }
}
```

### Ejemplo con NAT Gateway Regional (Modo Automático - Recomendado)

```hcl
module "vpc" {
  source = ""
  
  providers = {
    aws.project = aws.project
  }

  # Common configuration
  client        = "example"
  project       = "example"
  environment   = "dev"
  aws_region    = "us-east-1"

  # VPC configuration
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  #Subnet configuration
  subnet_config = {
    # NO se requieren subnets públicas para NAT Gateway Regional
    private = {
      public      = false
      include_nat = true
      subnets = [
        {
          cidr_block        = "10.0.1.0/24"
          availability_zone = "us-east-1a"
        },
        {
          cidr_block        = "10.0.2.0/24"
          availability_zone = "us-east-1b"
        },
        {
          cidr_block        = "10.0.3.0/24"
          availability_zone = "us-east-1c"
        }
      ]
      custom_routes = []
    }
  }

  # Gateway configuration
  create_igw = true
  create_nat = true
  nat_mode   = "regional"  # Nuevo: NAT Gateway Regional
  nat_regional_mode = "auto"  # AWS maneja IPs automáticamente

  # VPC Flow Logs configuration (obligatorio)
  flow_log_retention_in_days = 30

  # Additional tags (opcional)
  additional_tags = {
    ManagedBy  = "Terraform"
    Team       = "CloudOps"
    CostCenter = "Engineering"
  }
}
```

### Ejemplo con NAT Gateway Regional (Modo Manual)

```hcl
module "vpc" {
  source = ""
  
  providers = {
    aws.project = aws.project
  }

  # Common configuration
  client        = "example"
  project       = "example"
  environment   = "dev"
  aws_region    = "us-east-1"

  # VPC configuration
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  #Subnet configuration
  subnet_config = {
    private = {
      public      = false
      include_nat = true
      subnets = [
        {
          cidr_block        = "10.0.1.0/24"
          availability_zone = "us-east-1a"
        },
        {
          cidr_block        = "10.0.2.0/24"
          availability_zone = "us-east-1b"
        }
      ]
      custom_routes = []
    }
  }

  # Gateway configuration
  create_igw = true
  create_nat = true
  nat_mode   = "regional"
  nat_regional_mode = "manual"  # Control manual de IPs
  
  # Especificar EIPs por AZ (deben crearse previamente)
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

  # VPC Flow Logs configuration (obligatorio)
  flow_log_retention_in_days = 30

  # Additional tags (opcional)
  additional_tags = {
    ManagedBy  = "Terraform"
    Team       = "CloudOps"
    CostCenter = "Engineering"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.project"></a> [aws.project](#provider\_aws) | >= 4.31.0 |

## Resources

| Name | Type |
|------|------|
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_subnet.subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_route_table.route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.subnet_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route.internet_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.nat_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_eip.eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_nat_gateway.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.custom_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_iam_role.vpc_flow_logs_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy.vpc_flow_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.vpc_flow_logs_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_cloudwatch_log_group.vpc_flow_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_flow_log.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client"></a> [client](#input\_client) | Nombre del cliente | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Nombre del proyecto | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Entorno de despliegue | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Región de AWS donde se desplegará la VPC | `string` | n/a | yes |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | El bloque CIDR para la VPC | `string` | n/a | yes |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | Tenancy de las instancias lanzadas en la VPC | `string` | `"default"` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Habilitar soporte DNS para la VPC | `bool` | `true` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Habilitar nombres de host DNS para la VPC | `bool` | `true` | no |
| <a name="input_subnet_config"></a> [subnet\_config](#input\_subnet\_config) | Configuración de subredes y rutas personalizadas. Es un mapa donde cada clave representa un grupo de subredes (por ejemplo, 'public', 'private') y el valor es un objeto con la siguiente estructura:<br>- `public`: (bool) Indica si la subred es pública.<br>- `include_nat`: (bool, opcional) Indica si la subred privada debe incluir un NAT Gateway. Por defecto es false.<br>- `subnets`: (list) Una lista de objetos, cada uno representando una subred con las siguientes propiedades:<br>  - `cidr_block`: (string) El bloque CIDR para la subred.<br>  - `availability_zone`: (string) La zona de disponibilidad completa para la subred (ej: "us-east-1a").<br>- `custom_routes`: (list) Una lista de objetos, cada uno representando una ruta personalizada con las siguientes propiedades:<br>  - `destination_cidr_block`: (string) El bloque CIDR de destino para la ruta.<br>  - `carrier_gateway_id`: (string, opcional) ID del Carrier Gateway.<br>  - `core_network_arn`: (string, opcional) ARN de la red central.<br>  - `egress_only_gateway_id`: (string, opcional) ID del Egress Only Internet Gateway.<br>  - `nat_gateway_id`: (string, opcional) ID del NAT Gateway.<br>  - `local_gateway_id`: (string, opcional) ID del Local Gateway.<br>  - `network_interface_id`: (string, opcional) ID de la interfaz de red.<br>  - `transit_gateway_id`: (string, opcional) ID del Transit Gateway.<br>  - `vpc_endpoint_id`: (string, opcional) ID del VPC Endpoint.<br>  - `vpc_peering_connection_id`: (string, opcional) ID de la conexión de peering de VPC. | `map(object({`<br>`  public = bool`<br>`  include_nat = optional(bool, false)`<br>`  subnets = list(object({`<br>`    cidr_block = string`<br>`    availability_zone = string`<br>`  }))`<br>`  custom_routes = list(object({`<br>`    destination_cidr_block = string`<br>`    carrier_gateway_id = optional(string)`<br>`    core_network_arn = optional(string)`<br>`    egress_only_gateway_id = optional(string)`<br>`    nat_gateway_id = optional(string)`<br>`    local_gateway_id = optional(string)`<br>`    network_interface_id = optional(string)`<br>`    transit_gateway_id = optional(string)`<br>`    vpc_endpoint_id = optional(string)`<br>`    vpc_peering_connection_id = optional(string)`<br>`  }))`<br>`}))` | n/a | yes |
| <a name="input_create_igw"></a> [create\_igw](#input\_create\_igw) | Crear Internet Gateway | `bool` | `false` | no |
| <a name="input_create_nat"></a> [create\_nat](#input\_create\_nat) | Crear NAT Gateway | `bool` | `false` | no |
| <a name="input_nat_mode"></a> [nat\_mode](#input\_nat\_mode) | Modo de NAT Gateway: 'zonal' (uno por AZ, requiere subnets públicas) o 'regional' (único para toda la VPC, sin subnets públicas) | `string` | `"zonal"` | no |
| <a name="input_nat_regional_mode"></a> [nat\_regional\_mode](#input\_nat\_regional\_mode) | Modo de gestión de IPs para NAT Gateway Regional: 'auto' (AWS gestiona automáticamente) o 'manual' (especificar EIPs por AZ) | `string` | `"auto"` | no |
| <a name="input_nat_regional_az_config"></a> [nat\_regional\_az\_config](#input\_nat\_regional\_az\_config) | Configuración para NAT Gateway Regional en modo manual. Lista de objetos con availability_zone y allocation_ids | `list(object)` | `[]` | no |
| <a name="input_flow_log_retention_in_days"></a> [flow\_log\_retention\_in\_days](#input\_flow\_log\_retention\_in\_days) | Número de días para retener los logs de VPC Flow en CloudWatch | `number` | `30` | yes |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Tags adicionales para aplicar a todos los recursos creados por este módulo | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_id"></a> [vpc_id](#output\_vpc_id) | ID de la VPC creada |
| <a name="output_subnet_ids"></a> [subnet_ids](#output\_subnet_ids) | IDs de las sub redes creadas |
| <a name="output_route_table_ids"></a> [route_table_ids](#output\_route_table_ids) | IDs de la tablas de rutas creadas |
| <a name="output_nat_gateway_id"></a> [nat\_gateway\_id](#output\_nat\_gateway\_id) | ID del NAT Gateway (zonal o regional) |
| <a name="output_nat_gateway_mode"></a> [nat\_gateway\_mode](#output\_nat\_gateway\_mode) | Modo del NAT Gateway (zonal o regional) |
| <a name="output_regional_nat_gateway_route_table_id"></a> [regional\_nat\_gateway\_route\_table\_id](#output\_regional\_nat\_gateway\_route\_table\_id) | ID de la route table creada automáticamente por el NAT Gateway Regional (solo en modo regional) |
