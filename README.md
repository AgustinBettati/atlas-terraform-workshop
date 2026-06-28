# MongoDB Atlas + Terraform Workshop

Workshop guiado para desplegar **MongoDB Atlas con Terraform** desde cero, sin experiencia previa en Atlas ni en Terraform. A lo largo de la sesión vas a levantar **dos clusters distintos** y conectarte a ellos:

- **Lab 1:** un replica set single-region con **recursos de Terraform planos**.
- **Lab 2:** un replica set **multi-cloud** (AWS + Azure + GCP) con los **módulos oficiales** de Atlas.

Es un formato de **ejercicio guiado**: cada lab trae la estructura armada con un `# TODO` en `main.tf` que vas a completar siguiendo la documentación. Los dos labs despliegan sobre un **proyecto compartido que ya existe** (con private networking ya configurado); al terminar tenés los dos clusters corriendo en paralelo en ese proyecto.

> **Ramas del repo:** la rama `main` tiene los `main.tf` a medio completar (los `# TODO`). La rama `solution` tiene todo resuelto y validado, por si te trabás o querés comparar.

## Prerequisitos

| Necesitás | Detalle |
|-----------|---------|
| Una terminal | macOS / Linux / WSL |
| Un navegador | para la UI de Atlas en cloud.mongodb.com |
| Terraform `>= 1.9` | https://developer.hashicorp.com/terraform/install |
| `mongosh` | cliente de MongoDB: https://www.mongodb.com/docs/mongodb-shell/install/ |

Comprobá Terraform:

```bash
terraform version
```

**Duración estimada:** ~75 min (Lab 0 setup + Lab 1 + Lab 2).

---

## Lab 0 — Setup (hacelo antes de los labs)

### 1. Cuenta y proyecto compartido en Atlas

1. Registrate / entrá en https://cloud.mongodb.com.
2. El workshop usa un **proyecto que ya existe** y tiene el **private networking configurado** (private endpoints en las regiones que usan los labs). Quien administra el proyecto te pasa su **Project ID** (24 caracteres hex). Lo vas a pasar a Terraform como `project_id`.

> No creás ni la organización ni el proyecto: trabajás dentro del proyecto compartido. Por eso los `.tf` no tienen `org_id` ni crean `mongodbatlas_project`.

### 2. Service Account (cómo se autentica Terraform)

Terraform necesita credenciales para hablar con la API de Atlas. Usamos un **Service Account** (par OAuth `Client ID` / `Client Secret`).

1. En **Access Manager → Service Accounts → Create Service Account**.
2. Dale acceso al proyecto compartido con un rol que permita crear clusters y usuarios (p. ej. **`Project Owner`** sobre ese proyecto).
3. **Copiá el `Client Secret` en el momento**: se muestra una sola vez. Guardá `Client ID` y `Client Secret`.

> Un *Service Account* es la forma OAuth2 recomendada hoy; reemplaza a las viejas *API Keys* (par public/private). Para este workshop solo te importa que es el modo en que Terraform se autentica.

### 3. Terraform + credenciales

Instalá Terraform (link arriba) y verificá con `terraform version`.

El provider de Atlas detecta las credenciales automáticamente desde estas variables de entorno, así que **nunca van en los `.tf`**:

```bash
export MONGODB_ATLAS_CLIENT_ID="<TU_CLIENT_ID>"
export MONGODB_ATLAS_CLIENT_SECRET="<TU_CLIENT_SECRET>"
```

(Exportalas en la misma terminal donde vas a correr Terraform.)

### Mini-glosario

- **Provider:** plugin que Terraform usa para hablar con una API (acá, `mongodb/mongodbatlas`).
- **`terraform init`:** descarga el provider y los módulos.
- **`terraform plan`:** muestra qué va a crear/cambiar, sin aplicar.
- **`terraform apply`:** crea/actualiza la infraestructura de verdad.
- **State:** archivo donde Terraform recuerda lo que creó (`terraform.tfstate`). No lo edites a mano.

---

## Los labs

1. **[Lab 1 — recursos planos](lab1/README.md):** replica set single-region (proveedor/región configurable).
2. **[Lab 2 — módulos multi-cloud](lab2/README.md):** replica set en AWS + Azure + GCP.

Hacelos en orden. Cada uno tiene su propio README con objetivo, qué completar, enlaces a la documentación y el comando de limpieza (`terraform destroy`).

> **Recordá:** los clusters son **M10 dedicados** (facturables). No los dejes corriendo después de la sesión: destruí cada lab con `terraform destroy` (ver el README de cada lab).
