# Lab 1 — Replica set single-region con recursos planos

> Antes de empezar necesitás haber completado el [Lab 0 (setup)](../README.md): cuenta + organización, Service Account, Terraform instalado y las variables de entorno `MONGODB_ATLAS_CLIENT_ID` / `MONGODB_ATLAS_CLIENT_SECRET` exportadas. Además necesitás el **`project_id` del proyecto compartido** que ya existe y tiene el private networking configurado (te lo da quien administra el proyecto).

## Objetivo

Desplegar tu primer cluster de MongoDB Atlas usando **recursos de Terraform planos** (sin módulos), dentro de un **proyecto que ya existe**. Al terminar vas a tener un replica set de 3 nodos en una sola región y dos cadenas de conexión: una **pública** y una **privada** (vía private endpoint).

## Qué vas a completar

El archivo [`main.tf`](main.tf) ya tiene los 3 recursos esbozados, pero con un `# TODO` en cada uno. El proyecto no se crea acá: se pasa como `var.project_id`. Usando las variables de [`variables.tf`](variables.tf), tenés que completar:

1. `mongodbatlas_advanced_cluster` — el cluster (replica set) dentro de `var.project_id`.
2. `mongodbatlas_database_user` — el usuario para conectarte a la base.
3. `mongodbatlas_project_ip_access_list` — qué IPs pueden conectarse por la vía pública.

Los archivos `versions.tf`, `variables.tf` y `outputs.tf` ya están completos: no los toques.

## Documentación de referencia

Buscá los argumentos de cada recurso acá. Cada página tiene un ejemplo arriba de todo:

- `mongodbatlas_advanced_cluster`: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/advanced_cluster
- `mongodbatlas_database_user`: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user
- `mongodbatlas_project_ip_access_list`: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list
- Identificadores de región Atlas: https://www.mongodb.com/docs/atlas/cloud-providers-regions/

## Pistas de topología

- `cluster_type` = `REPLICASET`.
- `project_id` = `var.project_id` (el proyecto compartido ya existe).
- Una sola región: el proveedor y la región salen de las variables `cloud_provider` y `region_name` (no las hardcodees en `main.tf`). No tienen default, así que las pasás vos al `apply`; la descripción de `region_name` en [`variables.tf`](variables.tf) trae ejemplos de regiones de España para AWS, Azure y GCP (las mismas que usa el Lab 2).
- En el provider 2.0 `replication_specs` y `region_configs` son **listas de objetos** (sintaxis con `=` y `[ { ... } ]`, no bloques).
- 3 nodos electables (`electable_specs`), tamaño **M10**, `priority` = 7 (la región primaria del replica set).
- El usuario de base: `auth_database_name` = `admin` y un rol `readWriteAnyDatabase` sobre `admin`.

## Aplicar

```bash
terraform init
terraform plan  -var="project_id=<PROJECT_ID>" -var="db_password=<TU_PASSWORD>" -var="cloud_provider=AWS" -var="region_name=EU_SOUTH_2"
terraform apply -var="project_id=<PROJECT_ID>" -var="db_password=<TU_PASSWORD>" -var="cloud_provider=AWS" -var="region_name=EU_SOUTH_2"
```

> Usá un password **alfanumérico** (sin símbolos) para evitar tener que URL-encodearlo en la cadena de conexión.
> El `apply` crea el cluster y tarda **~7-10 min** (Atlas aprovisiona la infraestructura).

## Conectarte (público y privado)

El cluster expone **las dos vías al mismo tiempo**. Hay dos outputs, ambos con el usuario y el password ya embebidos:

```bash
# Público: funciona desde tu laptop si tu IP está en el access list del proyecto.
mongosh "$(terraform output -raw connection_string_public)"

# Privado: vía private endpoint. Solo es alcanzable desde DENTRO de la VPC/VNet
# del proyecto (no desde tu laptop). Sirve para una app que corre en esa red.
terraform output -raw connection_string_private
```

Una vez dentro (por la vía pública), probá una escritura y una lectura:

```javascript
use workshop
db.test.insertOne({ lab: 1, hola: "atlas" })
db.test.find()
```

### Sobre la cadena privada

`connection_string_private` sale de `connection_strings.private_endpoint`. Atlas solo la
devuelve si el proyecto tiene un **private endpoint configurado en cada región donde el
cluster tiene nodos**. Este lab usa una sola región (`var.region_name`), así que alcanza
con que el proyecto tenga el endpoint en esa región. Si el output vuelve vacío justo
después del `apply`, corré `terraform refresh` (el endpoint service tarda en quedar
`AVAILABLE`). Si el proyecto no tiene private networking en esa región, el output queda
en `null` y seguís usando la cadena pública.

## Notas

- `0.0.0.0/0` (abierto a todo Internet) es **solo para el taller**, para que cualquiera se pueda conectar desde su laptop. En un entorno real se restringe a IPs/CIDR conocidos.
- Estás trabajando sobre un **proyecto compartido**: el `ip_access_list` se suma a lo que ya haya. No borres el cluster todavía: en el Lab 2 vas a levantar un segundo cluster en el mismo proyecto.

## Limpieza

Cuando termines, destruí lo que creó este lab (desde `lab1/`):

```bash
terraform destroy -var="project_id=<PROJECT_ID>" -var="db_password=<TU_PASSWORD>" -var="cloud_provider=AWS" -var="region_name=EU_SOUTH_2"
```
