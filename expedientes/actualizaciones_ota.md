# Guía para Publicar Actualizaciones (OTA) en PioSystem

Este documento detalla el procedimiento paso a paso para lanzar una nueva versión de la aplicación y que esta llegue automáticamente a todos los dispositivos instalados.

## ⚠️ Consideración Crítica Inicial
**NUNCA pruebes el flujo final de actualización instalando la aplicación desde `flutter run` (Modo Debug).** Android bloquea por seguridad la instalación de un APK Release sobre una aplicación Debug. Siempre haz tus pruebas reales compilando el APK e instalándolo a mano primero.

---

## 🚀 Flujo Paso a Paso para Lanzar una Nueva Versión

### 1. Desarrollar la mejora
Haz todos los cambios visuales, correcciones o nuevas funciones en tu código fuente como siempre lo haces.

### 2. Subir la Versión en el Código
Abre el archivo `pubspec.yaml` que está en la raíz de tu proyecto y busca la línea que dice `version:`.
Incrementa el número de la versión.
> *Ejemplo: Si estabas en `version: 1.1.0+2`, cámbialo a `version: 1.2.0+3`.*

### 3. Compilar el APK (Producción)
Abre tu terminal en la raíz del proyecto y ejecuta el siguiente comando para generar el instalador optimizado:
```bash
flutter build apk --release
```
Cuando termine, el archivo `.apk` estará listo en la ruta:
`build/app/outputs/flutter-apk/app-release.apk`

### 4. Crear el Release en GitHub
1. Ve a tu repositorio en GitHub: https://github.com/deividlima1234/PioSystem
2. A la derecha, haz clic en **Releases** y luego en **Draft a new release**.
3. En la etiqueta (Tag), escribe el nombre de tu nueva versión (ej. `v1.2.0`).
4. Título de la release (ej. `Versión 1.2.0`).
5. Arrastra y suelta el archivo `app-release.apk` (que generaste en el paso 3) en el cuadro grande de adjuntos inferior.
6. Haz clic en **Publish release**.

### 5. Configurar el Enlace Directo
1. Una vez publicado el Release, verás tu archivo `app-release.apk` en la lista de Assets.
2. Haz **clic derecho** sobre él y selecciona **"Copiar dirección de enlace"**. 
   > *Debería ser un link parecido a: `https://github.com/deividlima1234/PioSystem/releases/download/v1.2.0/app-release.apk`*

### 6. Disparar la Actualización (Modificar `update.json`)
Abre el archivo `update.json` que está en la raíz de tu proyecto y edítalo para que coincida con tu nueva versión:

```json
{
  "latestVersion": "1.2.0",
  "releaseNotes": "Versión 1.2.0\n- Nueva pantalla de inventario.\n- Corrección de bugs menores.",
  "downloadUrl": "PEGA_AQUÍ_EL_ENLACE_QUE_COPIASTE_EN_EL_PASO_5",
  "isMandatory": false
}
```

### 7. ¡Enviar la Señal!
Para que los celulares detecten el cambio, solo tienes que subir este archivo `update.json` modificado a GitHub mediante estos comandos:
```bash
git add update.json
git commit -m "chore: lanzar actualizacion v1.2.0"
git push
```

**¡LISTO! 🎉** 
Apenas termine el `git push`, cualquier cliente que abra su aplicación PioSystem recibirá el modal de descarga inmediatamente.
