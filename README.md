# Gaara Planner

App Flutter para organizar clases, tareas, recordatorios y notas desde el dispositivo.

## Preparar release para Play Store

1. Verifica que Flutter este instalado y disponible en la terminal:

   ```bash
   flutter doctor
   ```

2. Genera el keystore de produccion:

   ```bash
   keytool -genkey -v -keystore android/app/gaara-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias gaara
   ```

3. Copia `android/key.properties.example` como `android/key.properties` y reemplaza los passwords reales.

4. Sube el version code antes de cada publicacion en `pubspec.yaml`, por ejemplo:

   ```yaml
   version: 1.0.1+2
   ```

5. Compila el Android App Bundle:

   ```bash
   flutter clean
   flutter pub get
   flutter analyze
   flutter test
   flutter build appbundle --release
   ```

El archivo para Play Console queda en `build/app/outputs/bundle/release/app-release.aab`.
