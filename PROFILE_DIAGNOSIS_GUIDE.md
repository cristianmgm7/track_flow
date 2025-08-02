# Profile Diagnosis Guide

## 🎯 **Problema Actual**

Los logs muestran que el perfil no se encuentra, pero hay dos usuarios diferentes:

- `mqpvqDVKcHVg10RzhkgamyfeDnI2` (en logs de sync)
- `ybsF3kH4JMV6qxavUS0DxKlQDpA3` (en logs de user profile)

## 🔍 **Diagnóstico Paso a Paso**

### **1. Verificar qué usuario está activo**

Los logs muestran inconsistencias en el userId. Esto puede indicar:

- Cambio de usuario sin limpiar cache
- Problema en el session storage
- Múltiples usuarios autenticados

### **2. Verificar si el perfil existe en Firestore**

Con los logs añadidos, ahora deberías ver:

```
[USER_PROFILE_REMOTE] Attempting to get profile from Firestore for userId: ybsF3kH4JMV6qxavUS0DxKlQDpA3
[USER_PROFILE_REMOTE] Firestore query completed - exists: true/false
```

### **3. Verificar el estado local vs remoto**

Los logs te mostrarán:

```
[USER_PROFILE_REPOSITORY] Profile exists locally: true/false
[USER_PROFILE_REPOSITORY] Profile exists in Firestore but not in local cache: true/false
```

## 🧪 **Testing Commands**

### **Para diagnosticar manualmente:**

1. **Limpiar cache local**:

   ```dart
   // En la consola de debug
   await sl<UserProfileLocalDataSource>().clearCache();
   ```

2. **Verificar userId actual**:

   ```dart
   // En la consola de debug
   final userId = await sl<SessionStorage>().getUserId();
   print('Current userId: $userId');
   ```

3. **Forzar diagnóstico**:
   ```dart
   // En la consola de debug
   context.read<UserProfileBloc>().add(DiagnoseProfileState());
   ```

## 📊 **Logs Esperados**

### **Si el perfil existe en Firestore pero no en local:**

```
[USER_PROFILE_REMOTE] Firestore query completed - exists: true
[USER_PROFILE_REMOTE] Profile found in Firestore, parsing data
[USER_PROFILE_REMOTE] Profile parsed successfully - name: xxx, email: xxx
[WATCH_USER_PROFILE] Profile synced from remote successfully - name: xxx, email: xxx
```

### **Si el perfil NO existe en Firestore:**

```
[USER_PROFILE_REMOTE] Firestore query completed - exists: false
[USER_PROFILE_REMOTE] Profile does not exist in Firestore for userId: xxx
[WATCH_USER_PROFILE] Profile does not exist in Firestore for userId: xxx
```

### **Si hay problema de conexión:**

```
[WATCH_USER_PROFILE] No internet connection for sync
[USER_PROFILE_REPOSITORY] No internet connection, cannot check remote
```

## 🚨 **Posibles Causas**

### **1. Perfil no existe en Firestore**

- El usuario nunca creó su perfil
- El perfil fue eliminado
- Problema en la creación inicial

### **2. Inconsistencia de userId**

- Cambio de usuario sin limpiar cache
- Problema en el session storage
- Múltiples autenticaciones

### **3. Problema de sincronización**

- Cache local corrupto
- Problema de red
- Error en la sincronización

## 🔧 **Soluciones**

### **Si el perfil no existe:**

1. Redirigir al usuario a la pantalla de creación de perfil
2. Verificar que el flujo de creación funciona correctamente

### **Si hay inconsistencia de userId:**

1. Limpiar cache local
2. Verificar session storage
3. Re-autenticar al usuario

### **Si hay problema de sincronización:**

1. Forzar sincronización manual
2. Verificar conectividad
3. Revisar logs de error

## 📋 **Checklist de Diagnóstico**

- [ ] Verificar userId actual en session storage
- [ ] Verificar si el perfil existe en Firestore
- [ ] Verificar estado del cache local
- [ ] Verificar conectividad de red
- [ ] Revisar logs de error detallados
- [ ] Probar sincronización manual

---

**Status**: 🔍 **DIAGNÓSTICO EN CURSO**  
**Próximo paso**: Ejecutar diagnóstico y revisar logs detallados
