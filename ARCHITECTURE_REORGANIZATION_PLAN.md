# 🏗️ Architecture Reorganization Plan - SOLID Principles

## 📋 **Problema Identificado**

La arquitectura actual viola principios SOLID:

### **🚨 Violaciones Críticas**

1. **SRP (Single Responsibility)**: `session_manager` y `sync` mezclan responsabilidades
2. **DIP (Dependency Inversion)**: Dependencias directas entre capas
3. **ISP (Interface Segregation)**: Interfaces con responsabilidades mezcladas
4. **OCP (Open/Closed)**: Difícil extender sin modificar código existente

---

## 🎯 **Solución: Separación Clara de Responsabilidades**

### **📁 Nueva Estructura de Directorios**

```
lib/core/
├── session/                    # 🎭 GESTIÓN DE SESIÓN PURA
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── user_session.dart
│   │   │   └── session_state.dart
│   │   ├── repositories/
│   │   │   └── session_repository.dart
│   │   └── usecases/
│   │       ├── initialize_session_usecase.dart
│   │       ├── check_authentication_usecase.dart
│   │       └── sign_out_usecase.dart
│   ├── data/
│   │   ├── repositories/
│   │   │   └── session_repository_impl.dart
│   │   └── datasources/
│   │       └── session_storage.dart
│   └── presentation/
│       ├── bloc/
│       │   ├── session_bloc.dart
│       │   ├── session_events.dart
│       │   └── session_state.dart
│       └── mixins/
│           └── session_aware_mixin.dart
│
├── sync/                       # 🔄 SINCRONIZACIÓN PURA
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── sync_state.dart
│   │   │   ├── sync_metadata.dart
│   │   │   └── sync_conflict.dart
│   │   ├── repositories/
│   │   │   ├── sync_repository.dart
│   │   │   └── pending_operations_repository.dart
│   │   └── usecases/
│   │       ├── initialize_sync_usecase.dart
│   │       ├── trigger_background_sync_usecase.dart
│   │       └── resolve_conflict_usecase.dart
│   ├── data/
│   │   ├── repositories/
│   │   │   ├── sync_repository_impl.dart
│   │   │   └── pending_operations_repository_impl.dart
│   │   ├── models/
│   │   │   ├── sync_metadata_document.dart
│   │   │   └── sync_operation_document.dart
│   │   └── services/
│   │       ├── background_sync_coordinator.dart
│   │       ├── conflict_resolution_service.dart
│   │       └── network_state_manager.dart
│   └── presentation/
│       ├── bloc/
│       │   ├── sync_bloc.dart
│       │   ├── sync_events.dart
│       │   └── sync_state.dart
│       └── mixins/
│           └── sync_aware_mixin.dart
│
├── app_flow/                   # 🚀 ORQUESTACIÓN DE FLUJO
│   ├── domain/
│   │   ├── entities/
│   │   │   └── app_flow_state.dart
│   │   └── usecases/
│   │       └── determine_app_flow_usecase.dart
│   ├── data/
│   │   └── services/
│   │       └── app_flow_coordinator.dart
│   └── presentation/
│       ├── bloc/
│       │   ├── app_flow_bloc.dart
│   │   │   ├── app_flow_events.dart
│   │   │   └── app_flow_state.dart
│       └── services/
│           └── navigation_service.dart
```

---

## 🔧 **Implementación Paso a Paso**

### **FASE 1: Separar Entidades (SRP)**

#### **1.1 Crear UserSession Pura**

```dart
// lib/core/session/domain/entities/user_session.dart
class UserSession {
  final User? currentUser;
  final bool isOnboardingCompleted;
  final bool isProfileComplete;
  final SessionState state;
  final String? errorMessage;

  // NO incluye información de sync
  // NO incluye syncProgress
  // NO incluye isSyncComplete
}
```

#### **1.2 Crear SyncState Pura**

```dart
// lib/core/sync/domain/entities/sync_state.dart
class SyncState {
  final SyncStatus status;
  final double progress;
  final DateTime? lastSyncTime;
  final String? errorMessage;

  // NO incluye información de usuario
  // NO incluye información de sesión
}
```

### **FASE 2: Crear Abstracciones (DIP)**

#### **2.1 Session Repository Interface**

```dart
// lib/core/session/domain/repositories/session_repository.dart
abstract class SessionRepository {
  Future<Either<Failure, UserSession>> getCurrentSession();
  Future<Either<Failure, Unit>> signOut();
  Stream<UserSession> watchSession();
}
```

#### **2.2 Sync Repository Interface**

```dart
// lib/core/sync/domain/repositories/sync_repository.dart
abstract class SyncRepository {
  Future<Either<Failure, SyncState>> getCurrentSyncState();
  Future<Either<Failure, Unit>> triggerBackgroundSync();
  Stream<SyncState> watchSyncState();
}
```

### **FASE 3: Orquestador de Flujo (OCP)**

#### **3.1 App Flow Coordinator**

```dart
// lib/core/app_flow/data/services/app_flow_coordinator.dart
@lazySingleton
class AppFlowCoordinator {
  final SessionRepository _sessionRepository;
  final SyncRepository _syncRepository;

  // Coordina pero NO implementa lógica de negocio
  Future<AppFlowState> determineAppFlow() async {
    final session = await _sessionRepository.getCurrentSession();
    final syncState = await _syncRepository.getCurrentSyncState();

    return _mapToAppFlowState(session, syncState);
  }
}
```

### **FASE 4: BLoCs Especializados (SRP)**

#### **4.1 Session BLoC (Solo Sesión)**

```dart
// lib/core/session/presentation/bloc/session_bloc.dart
@injectable
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final SessionRepository _sessionRepository;

  // Solo maneja eventos de sesión
  // NO maneja sync
  // NO maneja navegación
}
```

#### **4.2 Sync BLoC (Solo Sincronización)**

```dart
// lib/core/sync/presentation/bloc/sync_bloc.dart
@injectable
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncRepository _syncRepository;

  // Solo maneja eventos de sync
  // NO maneja sesión
  // NO maneja navegación
}
```

#### **4.3 App Flow BLoC (Solo Orquestación)**

```dart
// lib/core/app_flow/presentation/bloc/app_flow_bloc.dart
@injectable
class AppFlowBloc extends Bloc<AppFlowEvent, AppFlowState> {
  final AppFlowCoordinator _coordinator;

  // Solo orquesta el flujo
  // NO implementa lógica de negocio
  // NO maneja sync directamente
  // NO maneja sesión directamente
}
```

---

## 🎯 **Beneficios de la Nueva Arquitectura**

### **✅ Principios SOLID Respetados**

1. **SRP**: Cada clase tiene una sola responsabilidad
2. **OCP**: Fácil extender sin modificar código existente
3. **LSP**: Interfaces consistentes y predecibles
4. **ISP**: Interfaces pequeñas y específicas
5. **DIP**: Dependencias a través de abstracciones

### **✅ Separación de Responsabilidades**

- **Session**: Solo gestión de sesión de usuario
- **Sync**: Solo sincronización de datos
- **App Flow**: Solo orquestación de flujo de la app

### **✅ Testabilidad Mejorada**

- Cada componente se puede testear de forma aislada
- Mocks más simples y específicos
- Tests más rápidos y confiables

### **✅ Mantenibilidad**

- Cambios en sync no afectan session
- Cambios en session no afectan sync
- Código más fácil de entender y modificar

---

## 🚀 **Plan de Migración**

### **Semana 1: Separar Entidades**

1. Crear `UserSession` pura
2. Crear `SyncState` pura
3. Actualizar `AppSession` para usar composición

### **Semana 2: Crear Abstracciones**

1. Definir interfaces de repositorios
2. Implementar repositorios especializados
3. Actualizar use cases

### **Semana 3: Orquestador de Flujo**

1. Crear `AppFlowCoordinator`
2. Refactorizar `AppFlowBloc`
3. Actualizar navegación

### **Semana 4: BLoCs Especializados**

1. Crear `SessionBloc`
2. Crear `SyncBloc`
3. Migrar mixins

### **Semana 5: Testing y Limpieza**

1. Actualizar tests
2. Limpiar imports
3. Documentar nueva arquitectura

---

## 📊 **Métricas de Éxito**

- **Reducción de acoplamiento**: < 3 dependencias por clase
- **Tiempo de compilación**: -20%
- **Cobertura de tests**: > 90%
- **Complejidad ciclomática**: < 10 por método
- **Líneas de código por clase**: < 200

Esta reorganización transformará tu código en una arquitectura profesional, mantenible y escalable.
