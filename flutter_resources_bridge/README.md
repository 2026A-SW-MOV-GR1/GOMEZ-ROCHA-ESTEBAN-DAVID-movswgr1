## Flutter ↔ Android Resources (sin `intl` / sin `.arb`)

Este mini-ejemplo implementa el requisito del desafío:

- Flutter **NO** usa `intl` ni `.arb`.
- Flutter invoca Android (Kotlin) vía `MethodChannel`.
- Android consulta `Context`/`Resources` para obtener **texto** y **colores** definidos en `res/values*`.
- Cuando rota la pantalla o cambia el idioma, Flutter **vuelve a invocar** el código nativo para refrescar la UI.

### 1) Recursos Android

Ya tienes recursos en este repo (módulo `capitulo01`) como:

- `capitulo01/app/src/main/res/values/textos.xml`
- `capitulo01/app/src/main/res/values-en/textos.xml`
- `capitulo01/app/src/main/res/values-land/textos.xml`
- `capitulo01/app/src/main/res/values-en-land/textos.xml`
- `capitulo01/app/src/main/res/values/colors.xml`
- `capitulo01/app/src/main/res/values-en/colors.xml`
- `capitulo01/app/src/main/res/values-land/colors.xml`
- `capitulo01/app/src/main/res/values-en-land/colors.xml`

En tu **proyecto Flutter**, copia estas carpetas a:

`android/app/src/main/res/`

(Flutter/Android solo resolverá recursos que estén dentro del `android/` del proyecto Flutter.)

### 2) Android (Kotlin): MethodChannel

En tu `android/app/src/main/kotlin/.../MainActivity.kt` (que extienda `FlutterActivity`), agrega el código del archivo:

- `android/MainActivity.kt` (incluido aquí)

### 3) Flutter (Dart): invocar en cambios de idioma/rotación

Copia:

- `lib/main.dart` (incluido aquí)

Este archivo:

- crea un `MethodChannel`
- lee `saludo`, `text_color`, `background_color`
- se suscribe a cambios con `WidgetsBindingObserver`
  - `didChangeLocales` (idioma)
  - `didChangeMetrics` (rotación / size change)

### 4) IDs esperados

Este ejemplo pide:

- `string`: `saludo`
- `color`: `text_color`, `background_color`

Si cambias nombres en XML, ajusta los IDs en Dart.

