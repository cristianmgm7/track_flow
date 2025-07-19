# TrackFlow End-to-End Test Suite

## 📋 Descripción

Este conjunto de tests end-to-end valida completamente los flujos de usuarios nuevos y antiguos en TrackFlow, detectando comportamientos erróneos en la cadena de navegación, estados de BLoC y redirecciones del router.

## 🎯 Objetivos

### Para Usuarios Nuevos

- ✅ Validar flujo completo: Splash → Auth → Onboarding → Profile Creation → Dashboard
- ✅ Verificar redirecciones correctas en cada paso
- ✅ Detectar errores en la cadena de navegación
- ✅ Validar manejo de errores (email inválido, contraseña débil, etc.)

### Para Usuarios Antiguos

- ✅ Validar acceso directo: Splash → Dashboard
- ✅ Verificar persistencia de sesión
- ✅ Validar sincronización de datos
- ✅ Detectar problemas de rendimiento

### Detección de Errores

- 🔍 **Bucles infinitos de redirección**
- 🔍 **Inconsistencias de estado entre BLoCs**
- 🔍 **Navegación a rutas inválidas**
- 🔍 **Elementos UI faltantes**
- 🔍 **Problemas de rendimiento**
- 🔍 **Memory leaks**
- 🔍 **Race conditions**

## 📁 Estructura de Archivos

```
integration_test/
├── helpers/
│   └── test_helpers.dart          # Helpers y utilidades para tests
├── new_user_flow_test.dart        # Tests para usuarios nuevos
├── returning_user_flow_test.dart  # Tests para usuarios antiguos
├── state_transition_test.dart     # Tests de transiciones de estado
├── error_detection_test.dart      # Tests de detección de errores
├── run_e2e_tests.sh              # Script de ejecución
└── README.md                     # Esta documentación
```

## 🚀 Ejecución de Tests

### Opción 1: Script Automatizado (Recomendado)

```bash
# Dar permisos de ejecución
chmod +x integration_test/run_e2e_tests.sh

# Ejecutar todos los tests
./integration_test/run_e2e_tests.sh
```

### Opción 2: Comando Flutter Directo

```bash
# Ejecutar tests específicos
flutter test integration_test/new_user_flow_test.dart
flutter test integration_test/returning_user_flow_test.dart
flutter test integration_test/state_transition_test.dart
flutter test integration_test/error_detection_test.dart

# Ejecutar todos los tests de integración
flutter test integration_test/
```

### Opción 3: Con Dispositivo Específico

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en dispositivo específico
flutter test integration_test/new_user_flow_test.dart --device-id=<device-id>
```

## 📊 Casos de Prueba

### 1. **New User Flow Tests** (`new_user_flow_test.dart`)

#### Casos Principales:

- **Flujo Completo**: Splash → Auth → Onboarding → Profile Creation → Dashboard
- **Google Sign-In**: Validar autenticación con Google
- **Magic Link**: Validar flujo de magic link
- **Manejo de Errores**: Email inválido, contraseña débil, errores de red

#### Validaciones:

- ✅ Redirección correcta a auth screen para usuarios no autenticados
- ✅ Completar signup exitosamente
- ✅ Redirección a onboarding después de autenticación
- ✅ Completar onboarding exitosamente
- ✅ Redirección a profile creation
- ✅ Completar profile creation exitosamente
- ✅ Acceso final al dashboard
- ✅ Verificar funcionalidades principales del dashboard

### 2. **Returning User Flow Tests** (`returning_user_flow_test.dart`)

#### Casos Principales:

- **Usuario Completo**: Splash → Dashboard (acceso directo)
- **Perfil Incompleto**: Splash → Profile Creation → Dashboard
- **Onboarding Incompleto**: Splash → Onboarding → Profile Creation → Dashboard
- **Persistencia de Sesión**: Verificar que la sesión se mantiene
- **Modo Offline**: Validar funcionalidad offline
- **Sincronización de Datos**: Verificar carga de datos del usuario

#### Validaciones:

- ✅ Acceso directo al dashboard para usuarios completos
- ✅ Redirección correcta según estado del perfil
- ✅ Carga correcta de datos del usuario
- ✅ Acceso a todas las funcionalidades principales
- ✅ Persistencia de sesión después de reiniciar app

### 3. **State Transition Tests** (`state_transition_test.dart`)

#### Casos Principales:

- **Transiciones de Estado**: Validar cambios correctos entre estados
- **Estados Iniciales**: Verificar estados iniciales de cada BLoC
- **Manejo de Errores**: Validar estados de error
- **Consistencia**: Verificar consistencia de estados entre reinicios
- **Cambios Concurrentes**: Detectar race conditions

#### Validaciones:

- ✅ Estados iniciales correctos para usuarios nuevos y antiguos
- ✅ Transiciones correctas entre AuthBloc, OnboardingBloc y UserProfileBloc
- ✅ Manejo apropiado de estados de error
- ✅ Consistencia de estados después de completar flujos
- ✅ Estabilidad ante cambios concurrentes de estado

### 4. **Error Detection Tests** (`error_detection_test.dart`)

#### Casos Principales:

- **Bucles Infinitos**: Detectar redirecciones infinitas
- **Inconsistencias de Estado**: Validar combinaciones inválidas de estados
- **Rutas Inválidas**: Verificar acceso a rutas no autorizadas
- **Elementos UI Faltantes**: Detectar elementos requeridos ausentes
- **Problemas de Rendimiento**: Medir tiempos de navegación
- **Memory Leaks**: Detectar fugas de memoria
- **Race Conditions**: Validar condiciones de carrera

#### Validaciones:

- ✅ No hay bucles infinitos de redirección
- ✅ Estados de BLoC son consistentes
- ✅ Usuarios no pueden acceder a rutas no autorizadas
- ✅ Todos los elementos UI requeridos están presentes
- ✅ Navegación completa en menos de 5 segundos
- ✅ No hay memory leaks detectables
- ✅ App permanece estable ante interacciones rápidas

## 🔧 Configuración

### Prerrequisitos

- Flutter SDK instalado
- Dispositivo o emulador disponible
- Dependencias del proyecto instaladas (`flutter pub get`)

### Configuración de Dispositivos

```bash
# Verificar dispositivos disponibles
flutter devices

# Configurar emulador (si es necesario)
flutter emulators --launch <emulator-id>
```

### Variables de Entorno (Opcional)

```bash
# Para tests con datos específicos
export TEST_USER_EMAIL="test@trackflow.com"
export TEST_USER_PASSWORD="TestPassword123!"
```

## 📈 Interpretación de Resultados

### ✅ Tests Exitosos

- **Verde**: Todos los tests pasaron
- **Flujo Completo**: Usuario puede navegar sin problemas
- **Estados Correctos**: BLoCs mantienen estados consistentes
- **Sin Errores**: No se detectaron comportamientos erróneos

### ❌ Tests Fallidos

- **Rojo**: Algunos tests fallaron
- **Revisar Logs**: Verificar mensajes de error específicos
- **Analizar Flujo**: Identificar dónde se rompe la cadena
- **Corregir Estados**: Verificar lógica de BLoCs y router

### ⚠️ Warnings

- **Amarillo**: Tests pasaron con advertencias
- **Revisar Performance**: Posibles problemas de rendimiento
- **Verificar UI**: Elementos UI pueden estar faltando
- **Optimizar**: Considerar mejoras en el flujo

## 🐛 Debugging

### Logs Detallados

```bash
# Ejecutar con logs detallados
flutter test integration_test/new_user_flow_test.dart --verbose
```

### Screenshots en Fallo

```bash
# Los tests automáticamente toman screenshots en caso de fallo
# Revisar carpeta: test_driver/screenshots/
```

### Debug Manual

```bash
# Ejecutar en modo debug
flutter test integration_test/new_user_flow_test.dart --debug
```

## 📝 Mantenimiento

### Actualizar Tests

- **Nuevas Funcionalidades**: Agregar tests para nuevas características
- **Cambios en UI**: Actualizar selectores de elementos
- **Cambios en Flujo**: Modificar secuencias de navegación
- **Nuevos Estados**: Agregar validaciones para nuevos estados de BLoC

### Agregar Nuevos Casos

1. Crear nuevo archivo de test en `integration_test/`
2. Implementar casos de prueba específicos
3. Agregar al script de ejecución `run_e2e_tests.sh`
4. Documentar en este README

### Optimización

- **Performance**: Monitorear tiempos de ejecución
- **Cobertura**: Asegurar cobertura completa de flujos
- **Estabilidad**: Reducir flakiness en tests
- **Mantenibilidad**: Refactorizar código duplicado

## 🤝 Contribución

### Reportar Bugs

1. Ejecutar tests que fallan
2. Capturar logs completos
3. Incluir información del dispositivo
4. Describir pasos para reproducir

### Mejorar Tests

1. Identificar gaps en cobertura
2. Proponer nuevos casos de prueba
3. Implementar mejoras de performance
4. Actualizar documentación

## 📚 Referencias

- [Flutter Integration Testing](https://docs.flutter.dev/cookbook/testing/integration/introduction)
- [BLoC Testing](https://bloclibrary.dev/#/testing)
- [GoRouter Testing](https://gorouter.dev/testing)
- [Flutter Test Framework](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)
