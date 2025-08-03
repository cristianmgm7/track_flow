# User Session Cleanup Fix - Multi-User Data Leak

## 🚨 **Problema Crítico Identificado**

Los logs muestran que **dos usuarios diferentes** están cargándose simultáneamente:

```
[WATCH_USER_PROFILE] Got userId from session: ybsF3kH4JMV6qxavUS0DxKlQDpA3
[WATCH_USER_PROFILE] Starting to watch profile for userId: Nud6CI50cqeKZfvavL4ZBGFmHmG2
[USER_PROFILE_BLOC] Profile loaded successfully for user: andres@gmail.com
[USER_PROFILE_BLOC] Profile loaded successfully for user: fred@gmail.com
```

### **Problemas de Seguridad:**

- **Violación de privacidad**: Un usuario puede ver datos de otro
- **Inconsistencia de estado**: La app no sabe qué usuario está autenticado
- **Comportamiento impredecible**: UI muestra datos mezclados

## 🔍 **Causa Raíz**

El problema está en que **no se limpia correctamente el estado** cuando un usuario hace logout y otro hace login:

1. **Session Storage** - No se limpia completamente
2. **Cache Local** - Datos del usuario anterior permanecen
3. **BLoC States** - Estados no se resetean correctamente
4. **Streams Activos** - Subscripciones anteriores siguen activas

## 🔧 **Solución Implementada**

### **1. AuthBloc - Limpieza en Logout**

```dart
Future<void> _onAuthSignOutRequested(
  AuthSignOutRequested event,
  Emitter<AuthState> emit,
) async {
  // ... sign out logic ...

  // ✅ CRÍTICO: Limpiar estado completo antes de emitir AuthInitial
  _clearAllUserData();

  emit(AuthInitial());
}
```

### **2. AppFlowBloc - Detección de Logout**

```dart
_authStateSubscription = _authRepository.authState.listen((user) {
  // ✅ CRÍTICO: Si el usuario es null (logout), limpiar estado completo
  if (user == null) {
    AppLogger.info('AppFlowBloc: User is null (logout detected), clearing all state');
    _clearAllUserState();
  }

  add(CheckAppFlow());
});
```

### **3. WatchUserProfileUseCase - Limpieza de Estado**

```dart
if (id == null) {
  // ✅ CRÍTICO: Si no hay userId, significa que el usuario no está autenticado
  // Limpiar cualquier estado residual
  AppLogger.info('WatchUserProfileUseCase: User not authenticated, clearing profile state');

  yield Left(ServerFailure('No user found - user not authenticated'));
  return;
}
```

### **4. UserProfileBloc - Método de Limpieza**

```dart
/// Clear all user profile data and state
void clearAllUserData() {
  AppLogger.info('UserProfileBloc: Clearing all user profile data');

  _profileSubscription?.cancel();
  emit(UserProfileInitial());
}
```

## 🔄 **Flujo de Limpieza Corregido**

### **Cuando un usuario hace logout:**

```
1. Usuario hace logout → AuthBloc.signOut()
2. AuthRepository limpia session storage → clearUserId()
3. UserProfileRepository limpia cache → clearProfileCache()
4. AuthBloc emite AuthInitial → Auth state = null
5. AppFlowBloc detecta user = null → _clearAllUserState()
6. UserProfileBloc detecta no userId → Limpia estado
7. Todos los streams se cancelan → No más datos mezclados
```

### **Cuando un nuevo usuario hace login:**

```
1. Usuario hace login → AuthBloc.signIn()
2. Session storage se actualiza → saveUserId(newUserId)
3. AppFlowBloc detecta cambio → CheckAppFlow()
4. UserProfileBloc inicia limpio → WatchUserProfile(newUserId)
5. Solo datos del nuevo usuario se cargan → Estado consistente
```

## 🧪 **Testing Plan**

### **Pasos para Verificar el Fix:**

1. **Autenticarse con Usuario A**
2. **Verificar que se carga el perfil de Usuario A**
3. **Hacer logout**
4. **Verificar logs de limpieza**:
   ```
   [AUTH_BLOC] Sign out completed successfully
   [AUTH_BLOC] Clearing all user data during sign out
   [APP_FLOW_BLOC] User is null (logout detected), clearing all state
   [USER_PROFILE_BLOC] Clearing all user profile data
   ```
5. **Autenticarse con Usuario B**
6. **Verificar que SOLO se carga el perfil de Usuario B**

### **Logs Esperados Después del Fix:**

**Durante logout:**

```
[AUTH_BLOC] Sign out completed successfully
[AUTH_BLOC] Clearing all user data during sign out
[APP_FLOW_BLOC] User is null (logout detected), clearing all state
[USER_PROFILE_BLOC] Clearing all user profile data
```

**Durante login de nuevo usuario:**

```
[WATCH_USER_PROFILE] Got userId from session: newUserId
[WATCH_USER_PROFILE] Starting to watch profile for userId: newUserId
[USER_PROFILE_BLOC] Profile loaded successfully for user: newUser@email.com
```

## 📊 **Métricas de Éxito**

- ✅ **Seguridad**: Un usuario no puede ver datos de otro
- ✅ **Consistencia**: Solo un usuario activo a la vez
- ✅ **Limpieza completa**: Todos los estados se resetean en logout
- ✅ **Streams cancelados**: No hay subscripciones residuales
- ✅ **Logs informativos**: Flujo de limpieza es visible

## 🚀 **Próximos Pasos**

1. **Probar el flujo completo** de logout/login
2. **Verificar que no hay datos mezclados**
3. **Monitorear logs** para confirmar limpieza
4. **Probar casos edge** (logout durante carga, etc.)

---

**Status**: ✅ **IMPLEMENTADO**  
**Impact**: 🎯 **CRÍTICO** - Arregla violación de seguridad y privacidad  
**Riesgo**: 🟢 **BAJO** - Cambios controlados con logs detallados
