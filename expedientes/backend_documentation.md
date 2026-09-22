# Documentación del Backend: PioSystem Cloud

PioSystem Cloud es el servidor de respaldo en la nube diseñado para la aplicación de punto de venta (POS) PioSystem. Está construido bajo una arquitectura robusta y segura utilizando **Java 17** y el framework **Spring Boot 3**, junto con **PostgreSQL** para el almacenamiento de datos.

## Arquitectura General

El backend opera como una API RESTful que se encarga de recibir, validar y almacenar copias de seguridad de los dispositivos móviles o tablets que utilizan la app PioSystem de forma local (Offline-First). 

Dado que la aplicación móvil almacena toda su información en una base de datos local (Isar Database), el backend utiliza una columna nativa tipo `JSONB` de PostgreSQL. Esto permite que en lugar de mapear docenas de tablas relacionales en el servidor, la aplicación envíe un único y masivo paquete de datos (JSON) que el servidor guarda de forma ultrarrápida.

### Tecnologías Utilizadas
- **Lenguaje:** Java 17
- **Framework Core:** Spring Boot 3
- **Base de Datos:** PostgreSQL
- **ORM:** Spring Data JPA (Hibernate 6)
- **Seguridad:** Spring Security con JSON Web Tokens (JWT)
- **Gestor de Dependencias:** Gradle
- **Infraestructura de Despliegue:** Cloudflare Zero Trust (Tunnels) en Servidor Ubuntu (Self-Hosted).

---

## Modelos de Datos (Entities)

La estructura de la base de datos se maneja principalmente a través de dos entidades, ubicadas en el paquete `com.piosystem.cloud.model`:

### 1. `Business` (Negocios)
Representa a un cliente/emprendedor que ha comprado PioSystem y tiene una suscripción activa a PioSystem Cloud.
- **id:** UUID principal.
- **name:** Nombre de la pollería o restaurante.
- **email:** Correo electrónico de acceso.
- **passwordHash:** Contraseña encriptada para el acceso.
- **ruc:** Documento de identidad del negocio.
- **subscriptionEndDate:** Fecha en que expira la suscripción de nube.
- **isActive:** Controla si la cuenta está habilitada o suspendida.

### 2. `Backup` (Respaldos)
Almacena el historial de sincronizaciones que un `Business` envía al servidor.
- **id:** UUID único del respaldo.
- **business:** Relación Muchos a Uno con la entidad `Business`.
- **uploadedAt:** Fecha y hora exacta de la subida.
- **appVersion:** Versión de la app cliente que generó el backup (útil para migraciones de estructura).
- **payload (JSONB):** Columna clave. Contiene absolutamente todos los datos crudos empaquetados desde Isar (Configuración, Productos, Órdenes y Tickets) en un formato JSON anidado que PostgreSQL puede indexar y buscar internamente.

---

## Seguridad (Spring Security & JWT)

Todo el backend está protegido contra accesos no autorizados. A excepción del endpoint de autenticación (`/login`), ninguna ruta es accesible si la petición HTTP no incluye una cabecera `Authorization: Bearer <token>`.

### Flujo de Seguridad:
1. **Configuración Inicial:** En `SecurityConfig.java`, se deshabilitan las sesiones de estado (`SessionCreationPolicy.STATELESS`) y se añade el filtro JWT antes de cualquier petición.
2. **Generación del Token:** El `JwtUtil.java` utiliza la clave maestra (definida en `application.properties` bajo `jwt.secret`) y el algoritmo **HMAC-SHA256** para firmar criptográficamente los tokens con una vigencia de 30 días.
3. **Validación:** El filtro `JwtRequestFilter.java` intercepta cada llamada. Extrae el Token Bearer, lo descifra, valida que no haya expirado y extrae el ID del negocio para inyectarlo en el contexto de seguridad (`SecurityContextHolder`).

---

## Endpoints Principales (Controladores)

### 1. Autenticación (`AuthController.java`)
Ruta encargada de verificar las credenciales del cliente.

- **URL:** `POST /api/v1/auth/login`
- **Body Esperado:** `{"email": "...", "password": "..."}`
- **Respuesta Exitosa (200 OK):**
  Devuelve el identificador del negocio y el Token JWT que el cliente (Celular/Tablet) deberá guardar localmente.
  ```json
  {
    "businessId": "b-001",
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
  ```

### 2. Sincronización de Datos (`BackupController.java`)
Controlador protegido encargado de empujar o recuperar copias de seguridad.

- **URL de Subida:** `POST /api/v1/backups/push`
  - **Requisito:** Cabecera `Authorization: Bearer <token>`.
  - **Lógica:** Valida que el negocio exista y que su fecha de suscripción (`subscriptionEndDate`) sea válida. Extrae el JSON completo y lo persiste en PostgreSQL con la fecha actual.
  - **Respuesta (200 OK):** Confirma la correcta recepción.

- **URL de Descarga:** `GET /api/v1/backups/pull`
  - **Requisito:** Cabecera `Authorization: Bearer <token>`.
  - **Lógica:** Busca en la base de datos el registro más reciente (`findFirstByBusinessIdOrderByUploadedAtDesc`) vinculado al negocio autenticado.
  - **Respuesta (200 OK):** Retorna exactamente el mismo `JSONB` crudo para que el dispositivo móvil restaure su base de datos Isar local.

---

## Despliegue (DevOps)

El backend está diseñado para ser alojado en infraestructura propia (Self-Hosted) optimizando costos.

1. **Compilación:** Se utiliza el comando `./gradlew build -x test` para empaquetar todo el servidor Tomcat y el código en un único archivo `piosystem-cloud.jar`.
2. **Ejecución de Producción:** El `.jar` se ejecuta en un servidor Ubuntu.
   ```bash
   java -jar piosystem-cloud.jar --server.port=8081
   ```
3. **Exposición (Cloudflare Tunnels):** En lugar de usar Port-Forwarding tradicional y Nginx Reverses Proxies locales, el servidor se comunica al mundo mediante el daemon `cloudflared`. El tráfico entra por `https://api-piosystem.tu-dominio.com`, es limpiado de ataques DDoS por la red global de Cloudflare, viaja por túneles cifrados y llega intacto y seguro al puerto local `8081` del servidor Ubuntu.
