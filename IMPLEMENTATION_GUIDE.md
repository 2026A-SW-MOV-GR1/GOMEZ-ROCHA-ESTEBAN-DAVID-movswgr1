# Sistema de Recursos Android con MethodChannel y Flutter

## Descripción General

Este proyecto implementa un sistema completo que permite a una aplicación Flutter acceder dinámicamente a recursos de Android (strings y colores) a través de **Platform Channels / MethodChannel**. El sistema detecta automáticamente cambios de idioma y orientación del dispositivo.

### Características Principales

✅ **Detección de Idioma**: Detecta automáticamente cambios de idioma (Español/Inglés)  
✅ **Detección de Orientación**: Detecta cambios de orientación (Vertical/Horizontal)  
✅ **MethodChannel**: Comunicación nativa entre Flutter y Android  
✅ **Sin dependencias externas**: No usa Intl ni archivos .arb  
✅ **Recursos nativos**: Acceso directo al Context y recursos de Android  

---

## Componentes Principales

### 1. **Android: ResourceProvider.kt**

Clase Kotlin que expone los recursos del sistema Android:

```kotlin
class ResourceProvider(private val context: Context) {
    fun getString(resourceName: String): String
    fun getColor(colorName: String): String
    fun getCurrentLanguage(): String
    fun getCurrentOrientation(): String
    fun getResources(): Map<String, Any>
}
```

### 2. **Android: FlutterResourceBridge.kt**

Servicio que configura el MethodChannel para Flutter:

```kotlin
class FlutterResourceBridge(
    private val flutterEngine: FlutterEngine,
    private val resourceProvider: ResourceProvider
) {
    fun setupChannel()
}
```

### 3. **Android: MainActivity.kt (Flutter)**

Implementa el MethodChannel handler en la actividad principal:

```kotlin
class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.myapplicationtest/resources"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Configura MethodChannel
    }
}
```

### 4. **Flutter: main.dart**

Aplicación Flutter que:
- Inicializa el MethodChannel: `com.example.myapplicationtest/resources`
- Escucha cambios de configuración del dispositivo
- Actualiza la UI automáticamente

---

## Archivo de Recursos de Android

### Estructura de Carpetas

```
app/src/main/res/
├── values/                      # Valores por defecto (Inglés, Vertical)
│   ├── strings.xml
│   └── colors.xml
├── values-es/                   # Español Vertical
│   └── strings.xml
├── values-en/                   # Inglés Vertical (opcional)
│   └── strings.xml
├── values-land/                 # Horizontal (Inglés)
│   ├── strings.xml
│   └── colors.xml
└── values-es-land/              # Español Horizontal
    └── strings.xml
```

### Configuradores de recursos en Android

| Carpeta | Idioma | Orientación | Utilizado cuando... |
|---------|--------|-------------|---------------------|
| values/ | EN (default) | Vertical | Sistema está en inglés y pantalla vertical |
| values-es/ | Español | Vertical | Sistema está en español y pantalla vertical |
| values-land/ | EN (default) | Horizontal | Sistema en inglés y pantalla horizontal |
| values-es-land/ | Español | Horizontal | Sistema en español y pantalla horizontal |

---

## Métodos del MethodChannel

### `getString(name: String) -> String`

```dart
final greeting = await platform.invokeMethod('getString', 
    {'name': 'greeting'});
```

### `getColor(name: String) -> String`

```dart
final color = await platform.invokeMethod('getColor', 
    {'name': 'text_color'});
// Retorna: "#1A237E" (vertical) o "#C62828" (horizontal)
```

### `getCurrentLanguage() -> String`

```dart
final lang = await platform.invokeMethod('getCurrentLanguage');
// Retorna: "es" o "en"
```

### `getCurrentOrientation() -> String`

```dart
final orientation = await platform.invokeMethod('getCurrentOrientation');
// Retorna: "portrait" o "landscape"
```

### `getResources() -> Map`

```dart
final Map<dynamic, dynamic> result = 
    await platform.invokeMethod('getResources');
```

---

## Flujo de Funcionamiento

### 1. Inicio de la Aplicación

```
MainActivity.configureFlutterEngine()
    ↓
MethodChannel('com.example.myapplicationtest/resources')
    ↓
setMethodCallHandler { call, result -> ... }
    ↓
Esperando llamadas desde Flutter
```

### 2. Carga Inicial (Flutter)

```
MyHomePage.initState()
    ↓
WidgetsBinding.addObserver(this)
    ↓
_loadResources() → platform.invokeMethod('getResources')
    ↓
Android retorna Map con todos los recursos
    ↓
setState() → rebuild() → UI con recursos
```

### 3. Cambio de Idioma del Sistema

```
Usuario: Configuración → Idioma → Español
    ↓
Android Context cambia de locale
    ↓
ActivityManager reinicia la Activity con nuevo locale
    ↓
Flutter detecta: didChangeLocales()
    ↓
_loadResources() → MethodChannel llama nuevamente
    ↓
ResourceProvider lee nuevo Context.configuration.locales
    ↓
Android busca en res/values-es/ (si está en horizontal: values-es-land/)
    ↓
Retorna nuevos strings y colores
    ↓
Flutter actualiza UI automáticamente
```

### 4. Cambio de Orientación

```
Usuario rota dispositivo a Landscape
    ↓
Android: android:configChanges="orientation" notifica
    ↓
Flutter detecta MediaQuery.of(context).orientation = Landscape
    ↓
_loadResources() llamado automáticamente
    ↓
ResourceProvider.getCurrentOrientation() retorna "landscape"
    ↓
Android busca en res/values-land/strings.xml
    ↓
Retorna strings y colores específicos para landscape
    ↓
Flutter reconstruye UI con layout horizontal
```

---

## Instalación y Ejecución

### Prerequisites
- Flutter SDK ≥ 3.0
- Android SDK API 28+
- Kotlin 1.9+

### Pasos

1. **Navegar al directorio del proyecto**
```bash
cd flutter_app
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar en emulador o dispositivo**
```bash
flutter run
```

4. **Testing: Detectar cambios de idioma**
   - En el dispositivo: Configuración → Idioma → Cambiar a Español
   - La app se actualizará automáticamente

5. **Testing: Detectar cambios de orientación**
   - Rotar el dispositivo a Landscape
   - En emulador: Ctrl + Flecha derecha
   - La UI mostrará strings y colores diferentes

---

## Cadena de Configuradores de Recursos

Android busca recursos en este orden de precedencia:

```
res/values-[idioma]-[región]-[orientación]-[densidad]/
→ res/values-[idioma]-[región]-[orientación]/
→ res/values-[idioma]-[región]/
→ res/values-[idioma]/
→ res/values/ (default)
```

## Ejemplo: Buscar "greeting"

**Escenario 1: Sistema en Español, Pantalla Vertical**
```
¿res/values-es-land/strings.xml? NO (es landscape)
¿res/values-es/strings.xml? SÍ → "¡Hola! Modo vertical"
```

**Escenario 2: Sistema en Español, Pantalla Horizontal**
```
¿res/values-es-land/strings.xml? SÍ → "¡Hola! Modo horizontal"
```

**Escenario 3: Sistema en Inglés (default), Pantalla Horizontal**
```
¿res/values-en-land/strings.xml? NO
¿res/values-land/strings.xml? SÍ → "Hello! Horizontal mode"
```

**Escenario 4: Sistema en Inglés (default), Pantalla Vertical**
```
¿res/values-en/strings.xml? NO
¿res/values/strings.xml? SÍ → "Hello! Vertical mode"
```

---

## Valores de Recursos

### Strings por contexto

| Recurso | Vertical EN | Vertical ES | Horizontal EN | Horizontal ES |
|---------|------------|-------------|---------------|---------------|
| greeting | "Hello! Vertical mode" | "¡Hola! Modo vertical" | "Hello! Horizontal mode" | "¡Hola! Modo horizontal" |
| orientation | "Orientation: Vertical" | "Orientación: Vertical" | "Orientation: Horizontal" | "Orientación: Horizontal" |
| app_label | "Hello welcome from Flutter" | "Hola bienvenido desde Flutter" | - | - |

### Colores por Orientación

| Color | Vertical | Horizontal |
|-------|----------|------------|
| text_color | #1A237E (Azul oscuro) | #C62828 (Rojo oscuro) |
| background_color | #E3F2FD (Azul claro) | #FFEBEE (Rojo claro) |
| font_color | #1A237E (Azul oscuro) | #C62828 (Rojo oscuro) |

---

## Manejo de Errores

### En Android

```kotlin
try {
    val resourceId = getStringResourceId(context, resourceName)
    if (resourceId != 0) {
        return context.getString(resourceId)
    } else {
        return "Resource not found: $resourceName"
    }
} catch (e: Exception) {
    return "Error: ${e.message}"
}
```

### En Flutter

```dart
try {
    final result = await platform.invokeMethod('getResources');
    setState(() { /* actualizar UI */ });
} on PlatformException catch (e) {
    debugPrint('Error: ${e.message}');
    setState(() { 
        greeting = 'Error: ${e.message}' 
    });
}
```

---

## Ventajas

✅ **Sin dependencias externas** - No usa Intl o .arb  
✅ **Nativo** - Acceso directo a Context y recursos de Android  
✅ **Automático** - Detecta cambios sin intervención manual  
✅ **Eficiente** - Consulta directa al framework  
✅ **Educativo** - Aprende cómo funciona Platform Channel  
✅ **Escalable** - Fácil agregar más recursos  

---

## Conclusión

Este sistema demuestra cómo:
1. Usar MethodChannel para comunicación nativa
2. Acceder a recursos de Android desde Flutter
3. Detectar cambios de localización y orientación
4. Implementar UI reactiva a cambios del sistema

El resultado es una aplicación that respeta completamente las preferencias del sistema operativo Android.

