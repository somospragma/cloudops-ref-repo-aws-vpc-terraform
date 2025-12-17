# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-12-17

### Añadido
- Variable `additional_tags` para aplicar tags adicionales a todos los recursos del módulo
- Soporte para tags personalizados siguiendo el mismo patrón del módulo EKS Cluster
- Archivo `locals.tf` para centralizar la generación de nombres de recursos

### Cambiado
- **BREAKING CHANGE**: Refactorización completa de nomenclatura usando `locals.tf`
- Todos los nombres de recursos ahora se generan de forma centralizada en `locals.tf`
- Simplificación del código en `main.tf` usando referencias a `local.*`
- Todos los recursos ahora soportan `additional_tags` mediante merge con tags base
- Actualizado sample vpc-regional con ejemplo de uso de additional_tags
- Mejorada la legibilidad y mantenibilidad del código siguiendo el patrón del módulo EKS

### Beneficios
- **Consistencia**: Todos los nombres siguen el mismo patrón centralizado
- **Mantenibilidad**: Cambios en nomenclatura solo requieren modificar `locals.tf`
- **Claridad**: El código en `main.tf` es más limpio y fácil de leer
- **Escalabilidad**: Fácil agregar nuevos recursos con nomenclatura consistente

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
