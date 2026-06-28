# Lab 2 — Replica set multi-cloud con el módulo oficial

> Requiere el [Lab 0 (setup)](../README.md) hecho y el **`project_id` del proyecto compartido** (el mismo del Lab 1). Podés tener el cluster del [Lab 1](../lab1/README.md) corriendo en paralelo: este lab crea un segundo cluster en el **mismo proyecto**.

## Objetivo

Desplegar un replica set **multi-cloud** (un nodo en AWS, uno en Azure y uno en GCP) usando el **módulo oficial `cluster`** de MongoDB Atlas en vez de recursos planos. Vas a ver cómo un módulo encapsula varios recursos y reduce el boilerplate respecto del Lab 1.

## Qué vas a completar

En [`main.tf`](main.tf) hay un `module` y dos recursos. El proyecto no se crea acá: se pasa como `var.project_id`.

1. `module "cluster"` — crea el cluster multi-cloud (tiene un `# TODO` en la lista `regions`).
2. `mongodbatlas_database_user` — el usuario de base (recurso plano, igual que en el Lab 1).
3. `mongodbatlas_project_ip_access_list` — ya viene resuelto en el scaffold (acceso público para el workshop).

`versions.tf`, `variables.tf` y `outputs.tf` ya están completos.

## Documentación de referencia

El módulo publica sus **inputs y outputs** en el Terraform Registry (pestaña *Inputs* / *Outputs*):

- Módulo `cluster`: https://registry.terraform.io/modules/terraform-mongodbatlas-modules/cluster/mongodbatlas/latest
- `mongodbatlas_database_user`: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user
- Identificadores de región Atlas: https://www.mongodb.com/docs/atlas/cloud-providers-regions/

## Pistas

**Módulo `cluster`:**
- `project_id` = `var.project_id`, `cluster_type` = `REPLICASET`.
- La clave es la lista `regions`: tres entradas, una por nube. Son las **mismas regiones que recomienda el Lab 1**:
  - AWS → `EU_SOUTH_2`
  - Azure → `SPAIN_CENTRAL`
  - GCP → `EUROPE_SOUTHWEST_1`
  - `node_count = 1` en cada una.
- **El orden de la lista define la prioridad de elección** (la primera es la primaria, priority 7). No hay un campo `priority` de entrada.
- No pongas `instance_size`: el módulo usa **M10** por defecto.

**Usuario de base:** idéntico al Lab 1 (`auth_database_name` = `admin`, rol `readWriteAnyDatabase`), con `project_id = var.project_id`.

## Aplicar

```bash
terraform init
terraform plan  -var="project_id=<PROJECT_ID>" -var="db_password=<TU_PASSWORD>"
terraform apply -var="project_id=<PROJECT_ID>" -var="db_password=<TU_PASSWORD>"
```

> `terraform init` acá descarga el módulo del Registry además del provider.
> El `apply` de un cluster multi-cloud puede tardar un poco más que el del Lab 1.

## Comprobar y conectarte (público y privado)

En la UI de Atlas, entrá al cluster y mirá la topología: vas a ver los **3 nodos repartidos en AWS, Azure y GCP**.

Igual que en el Lab 1, hay dos outputs con credenciales embebidas:

```bash
# Público: desde tu laptop (con tu IP en el access list).
mongosh "$(terraform output -raw connection_string_public)" --eval 'db.getSiblingDB("workshop").test.insertOne({lab:2}); db.getSiblingDB("workshop").test.find().toArray()'

# Privado: vía private endpoint, solo alcanzable desde dentro de la red del proyecto.
terraform output -raw connection_string_private
```

### Sobre la cadena privada en multi-cloud

`connection_string_private` sale de `connection_strings.private_endpoint`, y Atlas la
devuelve con una regla **all-or-nothing**: solo aparece si el proyecto tiene un private
endpoint en **cada** región donde el cluster tiene nodos. Como este cluster es
multi-cloud, eso significa endpoints en **las tres** regiones (AWS `EU_SOUTH_2`, Azure
`SPAIN_CENTRAL`, GCP `EUROPE_SOUTHWEST_1`). Si falta en alguna, el output queda en `null`
y seguís con la cadena pública. Si esperás la privada y vuelve vacía tras el `apply`,
corré `terraform refresh`.

## Notas

- Trabajás sobre el **mismo proyecto compartido** que el Lab 1: al terminar tenés dos clusters en ese proyecto.

## Limpieza

Destruí lo de este lab (desde `lab2/`), y acordate de hacer lo mismo en `lab1/`:

```bash
terraform destroy -var="project_id=<PROJECT_ID>" -var="db_password=<TU_PASSWORD>"
```
