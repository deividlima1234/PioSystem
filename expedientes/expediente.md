
markdown_content = """# Expediente de Desarrollo - PioSystem
**POWERED BY EDDAMCORE-SYSTEM**
*Fecha: Septiembre 2026*

---

## 1. Visión General del Proyecto

El presente documento define la arquitectura, diseño y flujo de **PioSystem**, un sistema de Punto de Venta (POS) diseñado específicamente para el rubro de pollerías y restaurantes de comida rápida. El enfoque principal es una arquitectura *Local-First* que garantiza la operatividad ininterrumpida frente a fallas de internet, incorporando un modelo de negocio escalable mediante suscripciones para copias de seguridad en la nube (SaaS).

### Objetivo Principal

Dotar a los emprendedores gastronómicos de una herramienta de facturación y control de ventas ultra rápida, segura e intuitiva, blindada contra la piratería y optimizada para pantallas táctiles (Tablets y All-In-One).

### 1.1 Identidad Visual y Diseño UI

La interfaz gráfica adopta una estética minimalista y tecnológica de alto contraste (Dark Mode), orientada a reducir la fatiga visual del cajero y proyectar la identidad de EddamCore-System.

* **Negro Profundo (#000000 / #0a0a0a):** Fondo principal de la aplicación. Otorga un aspecto premium, limpio y resalta los elementos interactivos.
* **Rojo Carmesí Neón (#ff003c):** Color de acción primaria. Utilizado para botones críticos ("Cobrar", "Cerrar Turno"), alertas, bordes de módulos activos y el branding principal. Estimula la velocidad y el apetito.
* **Blanco Puro (#ffffff):** Textos principales, montos a cobrar e íconos, asegurando legibilidad absoluta bajo cualquier condición de iluminación.

---

## 2. Arquitectura de Seguridad y Licenciamiento

PioSystem cuenta con un núcleo de seguridad diseñado para evitar la distribución ilegal, reventa no autorizada y alteración de los registros de venta locales.

### 2.1 Sistema de Activación de Hardware (El Candado)

La aplicación no puede utilizarse inmediatamente después de su instalación. Requiere un proceso de validación autorizado exclusivamente por el desarrollador (EddamCore-System):

* **Firma de Dispositivo:** Al instalarse, la aplicación captura el identificador físico del hardware (MAC Address / Android ID) y lo cifra.
* **Bloqueo Inicial:** La aplicación entra en modo bóveda solicitando un "Código de Acceso".
* **Validación Dual:**
  * *Online:* Si hay internet, la app valida un token contra el servidor privado y activa la licencia asociándola al hardware.
  * *Offline:* La app muestra un "Código de Equipo". El desarrollador procesa este código en su generador de llaves y entrega un PIN de activación algorítmico al cliente.

### 2.2 Cifrado y Almacenamiento (Isar Database)

Todos los datos se manejan localmente mediante **Isar Database**, garantizando operaciones de lectura/escritura en milisegundos. La seguridad de la información sigue estos principios:

* **Hashing de Credenciales:** Las contraseñas del administrador y los PINs de los cajeros se almacenan utilizando algoritmos de hash (SHA-256). Nunca se guarda texto plano.
* **Anticlonación:** Si el archivo de la base de datos se extrae e intenta montarse en otro dispositivo, el sistema detectará el cambio de firma de hardware y bloqueará el acceso automáticamente.

---

## 3. Flujos Operativos y Login Diario

### 3.1 Pantalla de Acceso (Login)

Diseñada para la máxima agilidad en el entorno de comida rápida. Soporta dos roles principales:

| Rol                              | Método de Acceso                               | Permisos                                                                                                                |
| :------------------------------- | :---------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------- |
| **Cajero (Operador)**      | PIN numérico de 4 dígitos (Pad en pantalla)   | Apertura de turno, toma de pedidos, emisión de comprobantes y manejo de cuentas abiertas.                              |
| **Administrador (Dueño)** | Correo electrónico + Contraseña alfanumérica | Gestión de catálogo, reportes de cierre de caja (Reporte Z), configuración de impresora y sincronización a la nube. |

### 3.2 Flujo de Ventas (Pre-pago vs. Pos-pago)

El núcleo de la Terminal de Ventas soporta los dos escenarios típicos de una pollería en su Fase 1 (sin mapa gráfico de mesas):

**Escenario A: Flujo Pre-Pago (Para Llevar / Fast Food)**

1. El cliente pide en mostrador (ej. 1/8 de Pollo + Gaseosa 1L).
2. El cajero selecciona los productos en la cuadrícula de acceso rápido.
3. Presiona el botón **COBRAR** (Rojo Carmesí).
4. Selecciona método de pago (Efectivo/Yape). La impresora térmica emite la comanda para cocina y el ticket de cliente al instante.

**Escenario B: Flujo Pos-Pago (Consumo en Salón)**

1. El cliente ingresa y pide su orden inicial.
2. El cajero arma el pedido en la terminal.
3. Presiona el botón **GUARDAR / ESPERA**.
4. Ingresa un identificador rápido (Ej. "Mesa 4" o "Cliente Carlos").
5. El pedido pasa al módulo de *Cuentas Abiertas*.
6. Al finalizar el consumo, el cajero abre la tarjeta de la cuenta, agrega extras si los hay, y procede con el botón **COBRAR**.

---

## 4. Estructura de Interfaz (Sidebar Navigation)

La navegación principal se realiza mediante un Menú Lateral Izquierdo permanente, ideal para retener la vista del área de trabajo en pantallas horizontales. Los módulos son:

* **Terminal de Ventas:** El área central contiene la cuadrícula de catálogo de productos. El panel derecho muestra el ticket actual, subtotales y los botones de acción gigantes (COBRAR / GUARDAR).
* **Cuentas Abiertas:** Cuadrícula de tarjetas visuales que muestran los pedidos en curso, con tiempo transcurrido y montos parciales.
* **Cierre de Caja:** Resumen del día (Ventas totales, desglose por método de pago, ranking de platos más vendidos). Botón para impresión del Reporte Z.
* **Catálogo:** Pantalla de administración para agregar, ocultar o modificar precios de los productos.
* **Configuración:** Panel técnico para sincronización Bluetooth/USB de la ticketera, datos de la pollería y activación de la suscripción Cloud (Backup).

---

## 5. Tecnologías y Plan de Desarrollo

### 5.1 Stack Tecnológico

* **Frontend & UI:** Flutter (Dart). Interfaz responsiva y multiplataforma, optimizada para Android POS y Windows.
* **Base de Datos Local:** Isar Database. Operaciones NoSQL ultrarrápidas, relaciones de objetos y queries locales en milisegundos.
* **Hardware IO:** Librerías ESC/POS de Flutter para comandos directos de impresión térmica (Bluetooth, Red, USB).
* **Backend (Fase 2):** Python/Node.js con PostgreSQL para la orquestación de copias de seguridad de las suscripciones premium.

### 5.2 Fases de Implementación

| Fase                                  | Hitos de Desarrollo                                                                                                                                                                                                       |
| :------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Fase 1: MVP Local**           | - Setup del proyecto en Flutter y diseño UI/UX.- Integración y modelado de datos en Isar Database.- Desarrollo de pantallas: Login, Activación, Terminal de Ventas, Cuentas Abiertas.- Integración del motor ESC/POS. |
| **Fase 2: SaaS & Backup**       | - Despliegue de servidor privado EddamCore-System.- Script de serialización de Isar a JSON para el Cierre de Caja.- Panel de suscripciones y envíos cifrados a la nube.                                                 |
| **Fase 3: Expansión (Futuro)** | - Integración de mapa gráfico de mesas drag-and-drop.- Control de inventario y descuento de insumos (Kardex).                                                                                                           |
| """                                   |                                                                                                                                                                                                                           |

md_path = '/mnt/data/Expediente_PioSystem_EddamCore.md'
with open(md_path, 'w', encoding='utf-8') as f:
    f.write(markdown_content)

print(f"file_tag: Expediente_PioSystem_EddamCore.md")
