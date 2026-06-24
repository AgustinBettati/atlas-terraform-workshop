# Lab 2 — Replica set multi-cloud con módulos oficiales

> Requiere el [Lab 0 (setup)](../README.md) hecho. Podés tener el cluster del [Lab 1](../lab1/README.md) corriendo en paralelo: este lab crea un **proyecto distinto**.

## Objetivo

Levantar un replica set **multi-cloud** (un nodo en AWS, uno en Azure y uno en GCP) usando los **módulos oficiales** de MongoDB Atlas en vez de recursos planos. Vas a ver cómo un módulo encapsula varios recursos y reduce el boilerplate respecto del Lab 1.

## Qué vas a completar

En [`main.tf`](main.tf) hay dos `module` y un recurso, cada uno con un `# TODO`:

1. `module "project"` — crea el proyecto y su lista de acceso por IP.
2. `module "cluster"` — crea el cluster multi-cloud.
3. `mongodbatlas_database_user` — el usuario de base (recurso plano, igual que en el Lab 1).

`versions.tf`, `variables.tf` y `outputs.tf` ya están completos.

## Documentación de referencia

Los módulos publican sus **inputs y outputs** en el Terraform Registry (pestaña *Inputs* / *Outputs*):

- Módulo `project`: https://registry.terraform.io/modules/terraform-mongodbatlas-modules/project/mongodbatlas/latest
- Módulo `cluster`: https://registry.terraform.io/modules/terraform-mongodbatlas-modules/cluster/mongodbatlas/latest
- `mongodbatlas_database_user`: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user
- Identificadores de región Atlas: https://www.mongodb.com/docs/atlas/cloud-providers-regions/

## Pistas

**Módulo `project`:** completá `org_id`, `name` y `tags`. La `ip_access_list` ya viene resuelta en el scaffold (con `skip_allow_all_validation = true`, porque el módulo rechaza `0.0.0.0/0` sin ese flag). Expone el output `id`, que vas a usar como `project_id` del cluster y del usuario (`module.project.id`).

**Módulo `cluster`:**
- `cluster_type` = `REPLICASET`.
- La clave es la lista `regions`: tres entradas, una por nube.
  - AWS → `EU_WEST_1`
  - Azure → `EUROPE_WEST`
  - GCP → `EUROPE_SOUTHWEST_1`
  - `node_count = 1` en cada una.
- **El orden de la lista define la prioridad de elección** (la primera es la primaria, priority 7). No hay un campo `priority` de entrada.
- No pongas `instance_size`: el módulo usa **M10** por defecto.

**Usuario de base:** idéntico al Lab 1 (`auth_database_name` = `admin`, rol `readWriteAnyDatabase`), pero con `project_id = module.project.id`.

## Aplicar

```bash
terraform init
terraform plan  -var="org_id=<TU_ORG_ID>" -var="db_password=<TU_PASSWORD>"
terraform apply -var="org_id=<TU_ORG_ID>" -var="db_password=<TU_PASSWORD>"
```

> `terraform init` acá descarga los módulos del Registry además del provider.
> El `apply` de un cluster multi-cloud puede tardar un poco más que el del Lab 1.

## Comprobar y conectarte

En la UI de Atlas, entrá al cluster y mirá la topología: vas a ver los **3 nodos repartidos en AWS, Azure y GCP**.

Conexión, igual que en el Lab 1:

```bash
mongosh "$(terraform output -raw connection_string)" --eval 'db.getSiblingDB("workshop").test.insertOne({lab:2}); db.getSiblingDB("workshop").test.find().toArray()'
```

## Notas

- Este proyecto es **distinto** al del Lab 1: al terminar tenés dos proyectos, cada uno con su cluster.

## Limpieza

Destruí lo de este lab (desde `lab2/`), y acordate de hacer lo mismo en `lab1/`:

```bash
terraform destroy -var="org_id=<TU_ORG_ID>" -var="db_password=<TU_PASSWORD>"
```
