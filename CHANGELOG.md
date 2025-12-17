# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2025-12-17

### 🚀 Añadido
- **NAT Gateway Regional**: Soporte completo para el nuevo modo de NAT Gateway de AWS
  - Variable `nat_mode` para elegir entre 'zonal' (por defecto) o 'regional'
  - Variable `nat_regional_mode` para modo automático o manual de IPs
  - Variable `nat_regional_az_config` para configuración manual de EIPs por AZ
  - Outputs adicionales: `nat_gateway_id`, `nat_gateway_mode`, `regional_nat_gateway_route_table_id`
- **Sistema de Tags Adicionales**: Variable `additional_tags` para aplicar tags personalizados a todos los recursos
  - Sigue el mismo patrón del módulo EKS Cluster
  - Permite agregar tags específicos como los requeridos por EKS (`kubernetes.io/role/elb`, etc.)
- **Nomenclatura Centralizada**: Archivo `locals.tf` para gestión centralizada de nombres de recursos
  - Todos los nombres de recursos se generan en un solo lugar
  - Facilita mantenimiento y consistencia
- **Variable `aws_region`**: Nueva variable obligatoria para especificar la región de AWS
- **Variable `project`**: Reemplaza `functionality` para mejor claridad semántica

### 🔧 Cambiado
- **BREAKING CHANGE**: Refactorización completa de nomenclatura usando `locals.tf`
  - Todos los nombres de recursos ahora se generan de forma centralizada
  - Simplificación del código en `main.tf` usando referencias a `local.*`
- Recurso `aws_nat_gateway.nat` renombrado a `aws_nat_gateway.nat_zonal` para claridad
- Recurso `aws_eip.eip` ahora solo se crea en modo zonal
- Recurso `aws_route.nat_route` ahora soporta ambos modos (zonal y regional)
- Todos los recursos ahora soportan `additional_tags` mediante merge con tags base
- Sample actualizado a `vpc-regional/` con ejemplo completo de NAT Regional

### 🐛 Corregido
- **CRITICAL FIX**: Corregida duplicación de región en availability_zone en `locals.tf`
  - El módulo estaba concatenando `${var.aws_region}${subnet.availability_zone}` resultando en valores inválidos como `us-east-1us-east-1a`
  - Ahora se usa directamente `subnet.availability_zone` que debe contener la AZ completa (ej: "us-east-1a")

### 📚 Documentación
- README.md completamente actualizado con:
  - Ejemplos de NAT Gateway Regional (modo auto y manual)
  - Comparación detallada entre modo Zonal vs Regional
  - Todos los ejemplos corregidos con AZ completas
  - Estructura del módulo actualizada incluyendo `locals.tf`
  - Variable `project` en lugar de `functionality`
  - Tabla de variables actualizada con `aws_region` y `additional_tags`

### ✨ Características del NAT Gateway Regional
- **Simplicidad**: Un solo NAT Gateway para toda la VPC
- **Sin subnets públicas**: No requiere subnets públicas para el NAT
- **Alta disponibilidad automática**: Se expande automáticamente a nuevas AZs
- **Mayor capacidad**: Hasta 32 IPs por AZ (vs 8 en modo zonal)
- **Route table automática**: Crea automáticamente route table con ruta al IGW
- **Más económico**: Un solo NAT Gateway en lugar de uno por AZ

### 🔄 Compatibilidad
- **100% compatible con versiones anteriores**: Por defecto usa modo 'zonal'
- No se requieren cambios en configuraciones existentes para mantener comportamiento actual
- Para usar modo regional, simplemente agregar `nat_mode = "regional"`

### 📝 Notas de Migración
- **IMPORTANTE**: Ahora debes pasar la availability_zone completa en tu configuración:
  ```hcl
  # ✅ CORRECTO
  availability_zone = "us-east-1a"
  
  # ❌ INCORRECTO (ya no funciona)
  availability_zone = "a"
  ```
- Si usas `functionality`, cámbiala a `project`
- Agrega la variable `aws_region` a tu configuración

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
