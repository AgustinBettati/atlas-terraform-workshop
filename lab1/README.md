# Lab 1 — Replica set single-region con recursos planos

> Antes de empezar necesitás haber completado el [Lab 0 (setup)](../README.md): cuenta + organización, Service Account, Terraform instalado y las variables de entorno `MONGODB_ATLAS_CLIENT_ID` / `MONGODB_ATLAS_CLIENT_SECRET` exportadas.

## Objetivo

Levantar tu primer cluster de MongoDB Atlas usando **recursos de Terraform planos** (sin módulos). Al terminar vas a tener un replica set de 3 nodos en una sola región y te vas a conectar con `mongosh`.

## Qué vas a completar

El archivo [`main.tf`](main.tf) ya tiene los 4 recursos esbozados, pero con un `# TODO` en cada uno. Usando las variables que ya están definidas en [`variables.tf`](variables.tf), tenés que completar:

1. `mongodbatlas_project` — el proyecto donde vive el cluster.
2. `mongodbatlas_advanced_cluster` — el cluster (replica set).
3. `mongodbatlas_database_user` — el usuario para conectarte a la base.
4. `mongodbatlas_project_ip_access_list` — qué IPs pueden conectarse.

Los archivos `versions.tf`, `variables.tf` y `outputs.tf` ya están completos: no los toques.

## Documentación de referencia

Buscá los argumentos de cada recurso acá. Cada página tiene un ejemplo arriba de todo:

- `mongodbatlas_project`: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project
- `mongodbatlas_advanced_cluster`: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/advanced_cluster
- `mongodbatlas_database_user`: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user
- `mongodbatlas_project_ip_access_list`: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list
- Identificadores de región Atlas: https://www.mongodb.com/docs/atlas/cloud-providers-regions/

## Pistas de topología

- `cluster_type` = `REPLICASET`.
- Una sola región: usá las variables `cloud_provider` y `region_name` (ya definidas en [`variables.tf`](variables.tf)) en vez de hardcodear el proveedor y la región. No tienen default, así que las pasás vos al `apply`; la descripción de `region_name` trae ejemplos de regiones de España para AWS, Azure y GCP.
- En el provider 2.0 `replication_specs` y `region_configs` son **listas de objetos** (sintaxis con `=` y `[ { ... } ]`, no bloques).
- 3 nodos electables (`electable_specs`), tamaño **M10**, `priority` = 7 (la región primaria del replica set).
- El usuario de base: `auth_database_name` = `admin` y un rol `readWriteAnyDatabase` sobre `admin`.

## Aplicar

```bash
terraform init
terraform plan  -var="org_id=<TU_ORG_ID>" -var="db_password=<TU_PASSWORD>" -var="cloud_provider=AWS" -var="region_name=EU_SOUTH_2"
terraform apply -var="org_id=<TU_ORG_ID>" -var="db_password=<TU_PASSWORD>" -var="cloud_provider=AWS" -var="region_name=EU_SOUTH_2"
```

> Usá un password **alfanumérico** (sin símbolos) para evitar tener que URL-encodearlo en la cadena de conexión.
> El `apply` crea proyecto + cluster y tarda **~7-10 min** (Atlas aprovisiona la infraestructura).

## Conectarte

El output `connection_string` ya trae el usuario y el password embebidos, listo para pegar:

```bash
mongosh "$(terraform output -raw connection_string)"
```

Una vez dentro, probá una escritura y una lectura:

```javascript
use workshop
db.test.insertOne({ lab: 1, hola: "atlas" })
db.test.find()
```

La misma cadena (`terraform output -raw connection_string`) sirve para **Compass** o para la `MONGODB_URI` de una aplicación real.

## Notas

- `0.0.0.0/0` (abierto a todo Internet) es **solo para el taller**, para que cualquiera se pueda conectar desde su laptop. En un entorno real se restringe a IPs/CIDR conocidos.
- No borres el cluster todavía: en el Lab 2 vas a levantar un segundo cluster y los dos van a convivir.

## Limpieza

Cuando termines, destruí todo lo que creó este lab (desde `lab1/`):

```bash
terraform destroy -var="org_id=<TU_ORG_ID>" -var="db_password=<TU_PASSWORD>" -var="cloud_provider=AWS" -var="region_name=EU_SOUTH_2"
```
