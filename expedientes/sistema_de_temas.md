# Documentación: Sistema de Temas Dinámicos de PioSystem

Esta documentación describe la arquitectura y el uso del sistema de temas dinámicos implementado en PioSystem, el cual permite transicionar de forma instantánea entre diferentes paletas de colores (Light/Dark Mode, u otros temas personalizados).

---

## 1. Concepto Core

El sistema de temas ha abandonado las variables estáticas globales (como `AppColors.primary`) para adoptar un enfoque basado en el **Contexto de Flutter** y **Providers**. Esto significa que los colores de la aplicación dependen del estado actual del gestor de temas (`ThemeProvider`), el cual notifica a toda la interfaz cuando el usuario decide cambiar el diseño.

### ¿Dónde vive la configuración?
Toda la lógica de colores y temas reside en `lib/theme/app_theme.dart`.

---

## 2. Cómo usar los colores en nuevos componentes

Al crear nuevas pantallas, botones o tarjetas, **NUNCA** debes usar colores fijos como `Colors.white`, `Colors.black`, o códigos hexadecimales `Color(0xFF...)`. 

Para aplicar un color, debes inyectarlo leyendo la paleta activa a través del contexto:

```dart
// CORRECTO
Container(
  color: context.colors.primary,
  child: Text("Hola", style: TextStyle(color: context.colors.textPrimary)),
)

// INCORRECTO
Container(
  color: Colors.blue, // NO: No se adaptará si cambiamos a tema oscuro
  child: Text("Hola", style: TextStyle(color: Colors.white)), // NO
)
```

### ⚠️ Regla de Oro: ¡Cuidado con el `const`!

Dado que `context.colors` depende del estado del árbol de widgets (`BuildContext`), **no puedes usar el prefijo `const`** en los widgets que consumen un color dinámico, ya que dejarían de ser constantes de tiempo de compilación.

```dart
// INCORRECTO (Causará error de compilación)
child: const Icon(Icons.star, color: context.colors.primary)

// INCORRECTO (La decoración no puede ser const si tiene un color dinámico)
decoration: const BoxDecoration(color: context.colors.surface)

// CORRECTO
child: Icon(Icons.star, color: context.colors.primary)
decoration: BoxDecoration(color: context.colors.surface)
```

---

## 3. ¿Cómo añadir una nueva paleta de colores?

Si en el futuro el cliente solicita, por ejemplo, un **Tema Verde Bosque**, el proceso es muy directo y se limita a editar `lib/theme/app_theme.dart`:

**Paso 1: Añadir el identificador en el Enum**
```dart
enum AppThemeType {
  darkRed,
  lightBlue,
  forestGreen, // <--- NUEVO TEMA
}
```

**Paso 2: Crear la instancia de la paleta en `AppColors`**
Baja hasta donde están definidos `AppColors.darkRed` y `AppColors.lightBlue`, y crea uno nuevo:
```dart
static const AppColors forestGreen = AppColors(
  isDark: false,
  primary: Color(0xFF2E7D32),
  primaryDark: Color(0xFF1B5E20),
  background: Color(0xFFF1F8E9),
  surface: Colors.white,
  // ... (llenar el resto de propiedades obligatorias respetando el diseño)
);
```

**Paso 3: Conectarlo en el `ThemeProvider`**
En el método `get colors`, agrega el caso para retornar tu nueva paleta:
```dart
AppColors get colors {
  switch (_currentTheme) {
    case AppThemeType.darkRed: return AppColors.darkRed;
    case AppThemeType.lightBlue: return AppColors.lightBlue;
    case AppThemeType.forestGreen: return AppColors.forestGreen; // <--- NUEVO
  }
}
```

**Paso 4: Añadir la opción en el Menú de Ajustes**
Para que el usuario pueda escogerlo, ve a `lib/screens/main_layout.dart` (en el método `_buildSettingsScreen`) y añade un nuevo `ListTile` que dispare:
```dart
context.read<ThemeProvider>().switchTheme(AppThemeType.forestGreen);
```

---

## 4. Persistencia

La preferencia del usuario nunca se pierde. Cada vez que se llama a `switchTheme()`, el índice del tema elegido se guarda internamente en el dispositivo usando `SharedPreferences`. Cuando el usuario abre la app de nuevo, se lee este valor automáticamente y la interfaz se pinta del color preferido antes de presentarse en pantalla.
