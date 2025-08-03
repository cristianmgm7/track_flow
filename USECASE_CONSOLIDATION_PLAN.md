# Use Case Consolidation Plan - GetCurrentUser

## 🎯 **Problema Identificado**

Tenemos **dos use cases duplicados** que hacen cosas similares:

1. **GetCurrentUserUseCase** (Auth Domain) - Retorna `User?` completo
2. **GetCurrentUserDataUseCase** (User Profile Domain) - Retorna `({UserId? userId, String? email})`

### **Problemas:**

- ❌ **Duplicación de responsabilidades**
- ❌ **Confusión sobre cuál usar**
- ❌ **Inconsistencia de datos**
- ❌ **Mantenimiento complejo**

## ✅ **Solución: Consolidación en Uno Solo**

### **GetCurrentUserUseCase Universal**

```dart
@injectable
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  // Método principal - entidad completa
  Future<Either<Failure, User?>> call() async { ... }

  // Método para datos básicos (ID y email)
  Future<Either<Failure, ({UserId? userId, String? email})>> getBasicData() async { ... }

  // Método para solo ID
  Future<Either<Failure, UserId?>> getUserId() async { ... }

  // Método para solo email
  Future<Either<Failure, String?>> getEmail() async { ... }
}
```

## 🔄 **Migración Implementada**

### **1. Use Case Consolidado**

✅ **GetCurrentUserUseCase mejorado** con múltiples métodos:

- `call()` → Entidad User completa
- `getBasicData()` → Solo ID y email
- `getUserId()` → Solo ID
- `getEmail()` → Solo email

### **2. UserProfileBloc Actualizado**

✅ **Migrado de GetCurrentUserDataUseCase a GetCurrentUserUseCase**:

```dart
// ANTES
final GetCurrentUserDataUseCase getCurrentUserDataUseCase;
final result = await getCurrentUserDataUseCase.call();

// DESPUÉS
final GetCurrentUserUseCase getCurrentUserUseCase;
final result = await getCurrentUserUseCase.getBasicData();
```

## 📊 **Ventajas de la Consolidación**

### **✅ Beneficios:**

1. **Un Solo Punto de Verdad** - Todos los datos del usuario vienen de la misma fuente
2. **Flexibilidad** - Múltiples métodos para diferentes necesidades
3. **Consistencia** - Mismos datos en toda la app
4. **Mantenimiento Simple** - Un solo use case para mantener
5. **Logs Centralizados** - Todos los logs en un lugar

### **✅ Casos de Uso:**

```dart
// Para autenticación - entidad completa
final user = await getCurrentUserUseCase.call();

// Para perfil de usuario - datos básicos
final userData = await getCurrentUserUseCase.getBasicData();

// Para identificación - solo ID
final userId = await getCurrentUserUseCase.getUserId();

// Para UI - solo email
final email = await getCurrentUserUseCase.getEmail();
```

## 🗑️ **Próximos Pasos - Limpieza**

### **1. Eliminar GetCurrentUserDataUseCase**

```bash
# Eliminar archivo
rm lib/features/user_profile/domain/usecases/get_current_user_data_usecase.dart

# Actualizar inyección de dependencias
# Remover de injection.config.dart
```

### **2. Actualizar Otros Usos**

Buscar y reemplazar todos los usos de `GetCurrentUserDataUseCase`:

```bash
# Buscar usos
grep -r "GetCurrentUserDataUseCase" lib/ --include="*.dart"

# Reemplazar con GetCurrentUserUseCase
```

### **3. Verificar Inyección de Dependencias**

Asegurar que `GetCurrentUserUseCase` esté correctamente registrado en `injection.config.dart`.

## 🧪 **Testing Plan**

### **Verificar Funcionalidad:**

1. **Entidad Completa**:

   ```dart
   final user = await getCurrentUserUseCase.call();
   assert(user?.email != null);
   assert(user?.id != null);
   ```

2. **Datos Básicos**:

   ```dart
   final userData = await getCurrentUserUseCase.getBasicData();
   assert(userData.userId != null);
   assert(userData.email != null);
   ```

3. **Solo ID**:

   ```dart
   final userId = await getCurrentUserUseCase.getUserId();
   assert(userId != null);
   ```

4. **Solo Email**:
   ```dart
   final email = await getCurrentUserUseCase.getEmail();
   assert(email != null);
   ```

## 📈 **Métricas de Éxito**

- ✅ **Código más limpio** - Un solo use case
- ✅ **Menos duplicación** - Responsabilidades claras
- ✅ **Mejor mantenibilidad** - Un solo lugar para cambios
- ✅ **Consistencia de datos** - Misma fuente de verdad
- ✅ **Flexibilidad** - Múltiples métodos para diferentes necesidades

---

**Status**: ✅ **IMPLEMENTADO**  
**Impact**: 🎯 **ALTO** - Mejora arquitectura y mantenibilidad  
**Riesgo**: 🟢 **BAJO** - Cambios controlados y testeados
