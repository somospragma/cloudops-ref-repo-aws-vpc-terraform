# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-12-15

### Añadido
- Soporte para NAT Gateway Regional (nuevo modo de AWS)
- Variable `nat_mode` para elegir entre 'zonal' (por defecto) o 'regional'
- Variable `nat_regional_mode` para modo automático o manual de IPs
- Variable `nat_regional_az_config` para configuración manual de EIPs por AZ
- Outputs adicionales: `nat_gateway_id`, `nat_gateway_mode`, `regional_nat_gateway_route_table_id`

### Características del NAT Gateway Regional
- **Simplicidad**: Un solo NAT Gateway para toda la VPC
- **Sin subnets públicas**: No requiere subnets públicas para el NAT
- **Alta disponibilidad automática**: Se expande automáticamente a nuevas AZs
- **Mayor capacidad**: Hasta 32 IPs por AZ (vs 8 en modo zonal)
- **Route table automática**: Crea automáticamente route table con ruta al IGW

### Cambiado
- Recurso `aws_nat_gateway.nat` renombrado a `aws_nat_gateway.nat_zonal` para claridad
- Recurso `aws_eip.eip` ahora solo se crea en modo zonal
- Recurso `aws_route.nat_route` ahora soporta ambos modos (zonal y regional)

### Compatibilidad
- **100% compatible con versiones anteriores**: Por defecto usa modo 'zonal'
- No se requieren cambios en configuraciones existentes
- Para usar modo regional, simplemente agregar `nat_mode = "regional"`

## [1.0.0] - 2024-10-18

### Añadido
- Lanzamiento inicial del módulo VPC.
- Creación de VPC con bloque CIDR configurable.
- Soporte para creación de subredes públicas y privadas.
- Configuración de Internet Gateway (IGW) opcional.
- Configuración de NAT Gateway opcional.
- Implementación de tablas de rutas para cada subred.
- Soporte para rutas personalizadas.
- Configuración del grupo de seguridad predeterminado de la VPC.
- Estructura del proyecto con carpetas `modules/vpc` y `sample`.
- README.md completo con descripción del módulo, estructura, inputs y outputs.
- Ejemplo de uso funcional en la carpeta `sample`.

### Cambiado
- N/A

### Eliminado
- N/A

### Corregido
- N/A

### Seguridad
- Configuración inicial de mínimos de seguridad.

## [1.0.1] - 2024-10-18

## [1.0.1] - 2025-01-13
### Update
- Zona de diponilibilidad.
### Añadido
- outputs Route Table - Subnet Id
