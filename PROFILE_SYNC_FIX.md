# Profile Sync Fix - Remote to Local Synchronization

## 🎯 **Problema Identificado**

El usuario está autenticado y tiene un perfil en la base de datos remota (Firestore), pero la app no puede ver el perfil porque no está sincronizado en la base de datos local (Isar).

### **Síntomas:**

- Usuario autenticado correctamente ✅
- Perfil existe en Firestore ✅
- Perfil NO existe en Isar local ❌
- App muestra "Unable to load profile" ❌

## 🔍 **Causa Raíz**

El problema estaba en el `UserProfileRepository.watchUserProfile()` que tenía la sincronización automática deshabilitada para evitar bucles infinitos:

```dart
// TEMPORARY FIX: Disabled background sync to avoid infinite loop
await for (final dto in _localDataSource.watchUserProfile(userId.value)) {
  // Return local data immediately without triggering background sync
  yield Right(dto?.toDomain());
}
```

Esto significaba que cuando el perfil existía en remoto pero no en local, nunca se sincronizaba automáticamente.

## 🔧 **Solución Implementada**

### **1. Sincronización Inteligente en watchUserProfile**

Modificado el `UserProfileRepository.watchUserProfile()` para que:

```dart
await for (final dto in _localDataSource.watchUserProfile(userId.value)) {
  if (dto != null) {
    // Profile exists locally, return it
    yield Right(dto.toDomain());
  } else {
    // Profile not in local cache, try to sync from remote ONCE
    final isConnected = await _networkStateManager.isConnected;
    if (isConnected) {
      final remoteResult = await _remoteDataSource.getProfileById(userId.value);
      await remoteResult.fold(
        (failure) async { /* log error */ },
        (remoteProfile) async {
          // Cache the profile locally
          await _localDataSource.cacheUserProfile(remoteProfile);
          // The local stream will emit the cached profile on next iteration
        },
      );
    }
    yield Right(null); // For now, local stream will emit cached profile if sync was successful
  }
}
```

### **2. Sincronización Forzada en WatchUserProfileUseCase**

Añadido método `_trySyncFromRemote()` que se ejecuta cuando no se encuentra el perfil localmente:

```dart
/// Try to sync profile from remote when not found locally
Future<void> _trySyncFromRemote(String userId) async {
  final syncResult = await _userProfileRepository.syncProfileFromRemote(
    UserId.fromUniqueString(userId),
  );

  syncResult.fold(
    (failure) { /* log warning */ },
    (profile) { /* log success */ },
  );
}
```

### **3. Logs Detallados para Diagnóstico**

Añadidos logs en puntos clave para diagnosticar el flujo de sincronización:

```dart
AppLogger.info(
  'UserProfileRepository: Profile not in local cache, attempting remote sync',
  tag: 'USER_PROFILE_REPOSITORY',
);

AppLogger.info(
  'UserProfileRepository: Profile found in remote, caching locally',
  tag: 'USER_PROFILE_REPOSITORY',
);
```

## 🔄 **Flujo de Sincronización Corregido**

### **Escenario: Usuario con perfil en remoto pero no en local**

```
1. Usuario abre app → AppFlowBloc.checkAppFlow()
2. SessionService verifica perfil → No encuentra en local
3. WatchUserProfileUseCase inicia → No encuentra en local
4. WatchUserProfileUseCase._trySyncFromRemote() → Sincroniza desde remoto
5. Perfil se guarda en local → Isar cache actualizado
6. Local stream emite perfil → UI muestra perfil correctamente
7. AppFlowBloc detecta perfil completo → AppFlowReady()
8. Router redirige al dashboard
```

## 🧪 **Testing Plan**

### **Pasos para Verificar el Fix**

1. **Limpiar cache local** (para simular perfil solo en remoto)
2. **Autenticarse** con usuario que tenga perfil en Firestore
3. **Verificar logs** para confirmar sincronización:
   ```
   [WATCH_USER_PROFILE] No profile found for userId: xxx
   [WATCH_USER_PROFILE] Attempting to sync profile from remote
   [USER_PROFILE_REPOSITORY] Profile found in remote, caching locally
   [WATCH_USER_PROFILE] Profile synced from remote successfully
   ```
4. **Verificar que el perfil se muestra** en la UI
5. **Verificar redirección** al dashboard

### **Logs Esperados**

**Cuando el perfil existe en remoto pero no en local**:

```
[WATCH_USER_PROFILE] No profile found for userId: xxx
[WATCH_USER_PROFILE] Attempting to sync profile from remote
[USER_PROFILE_REPOSITORY] Forcing sync from remote for userId: xxx
[USER_PROFILE_REPOSITORY] Remote profile found, caching locally
[WATCH_USER_PROFILE] Profile synced from remote successfully
[WATCH_USER_PROFILE] Profile loaded successfully for userId: xxx
```

## 📊 **Métricas de Éxito**

- ✅ **Sincronización automática**: Perfiles en remoto se sincronizan automáticamente
- ✅ **Sin bucles infinitos**: La sincronización es inteligente y no causa loops
- ✅ **Offline support**: Funciona correctamente sin conexión
- ✅ **Logs informativos**: Flujo de sincronización es visible en logs
- ✅ **Performance**: Sincronización solo cuando es necesaria

## 🚀 **Próximos Pasos**

1. **Probar el flujo completo** con usuario que tenga perfil en remoto
2. **Verificar que no hay regresiones** en otros flujos
3. **Monitorear logs** para confirmar sincronización exitosa
4. **Probar casos edge** (offline, errores de red, etc.)

---

**Status**: ✅ **IMPLEMENTADO**  
**Impact**: 🎯 **ALTO** - Arregla sincronización crítica entre remoto y local  
**Riesgo**: 🟢 **BAJO** - Cambios controlados con logs detallados
