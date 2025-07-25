# 🔍 Debug Guide: Authentication Flow Issue

## 🎯 **Problema**

La app se queda en la pantalla de auth después del login con un nuevo usuario.

## 📋 **Pasos para Debuggear**

### 1. **Ejecutar la app con logs detallados**

```bash
flutter run --debug
```

### 2. **Buscar estos logs específicos en orden:**

#### **A. Login Process:**

```
[AUTH_BLOC] Starting sign up process for email: [email]
[AUTH_BLOC] Sign up successful for new user: [email] (ID: [user_id])
```

#### **B. Auth Screen Response:**

```
[AUTH_SCREEN] Auth screen received state: AuthAuthenticated
[AUTH_SCREEN] Auth successful! User: [email] (ID: [user_id])
[AUTH_SCREEN] Triggering AppFlowBloc.checkAppFlow() after successful auth
```

#### **C. AppFlowBloc Processing:**

```
[APP_FLOW_BLOC] Starting simplified app flow check
[APP_BOOTSTRAP] Starting simplified app initialization
[APP_BOOTSTRAP] Performing simple auth check...
```

#### **D. SessionService Check:**

```
[SESSION_SERVICE] Starting getCurrentSession()
[SESSION_SERVICE] Step 1: Checking authentication status...
[SESSION_SERVICE] Authentication check result: true
[SESSION_SERVICE] Step 2: Getting current user...
[SESSION_SERVICE] Current user retrieved: [email] (ID: [user_id])
[SESSION_SERVICE] Step 3 & 4: Checking onboarding and profile completeness in parallel...
[SESSION_SERVICE] Onboarding completed: [true/false]
[SESSION_SERVICE] Profile completeness: [true/false]
```

#### **E. AppBootstrap Result:**

```
[APP_BOOTSTRAP] Auth check completed: [authenticated/ready]
[APP_BOOTSTRAP] App bootstrap completed successfully in [X]ms
[APP_FLOW_BLOC] App flow check completed: [Setup/Dashboard]
```

#### **F. Navigation Decision:**

```
[APP_ROUTER] Redirect called - flowState: [AppFlowState] currentLocation: /auth
[NAVIGATION] NavigationService: Evaluating route for state [AppFlowState] at location: /auth
[NAVIGATION] NavigationService: Handling [authenticated/ready] state
[APP_ROUTER] Redirecting from /auth to [onboarding/dashboard]
```

## 🚨 **Posibles Problemas y Soluciones**

### **Problema 1: SessionService retorna `unauthenticated`**

**Síntomas:**

- `[SESSION_SERVICE] Authentication check result: false`
- `[SESSION_SERVICE] User not authenticated, returning unauthenticated session`

**Causas posibles:**

- Firebase Auth no está sincronizado
- SessionStorage no guardó el user ID correctamente
- Network issues

**Solución:**

```dart
// Verificar en AuthRepositoryImpl
final userId = await _sessionStorage.getUserId();
print('Stored user ID: $userId');
```

### **Problema 2: Onboarding/Profile check falla**

**Síntomas:**

- `[SESSION_SERVICE] Onboarding check failed: [error]`
- `[SESSION_SERVICE] Profile completeness check failed: [error]`

**Causas posibles:**

- Database no inicializado
- Use cases no implementados correctamente
- Dependencias faltantes

### **Problema 3: NavigationService no redirige**

**Síntomas:**

- `[NAVIGATION] NavigationService: Staying on current route (not protected): /auth`
- No hay logs de redirección

**Causas posibles:**

- AppFlowState no se actualiza correctamente
- NavigationService lógica incorrecta

### **Problema 4: AppRouter no procesa redirect**

**Síntomas:**

- `[APP_ROUTER] No redirect needed, staying on /auth`
- El redirect no se ejecuta

**Causas posibles:**

- GoRouter no está configurado correctamente
- BlocListener no está escuchando cambios

## 🔧 **Comandos de Debug Adicionales**

### **Verificar SessionStorage:**

```dart
// Agregar en AuthRepositoryImpl.signUpWithEmailAndPassword
await _sessionStorage.saveUserId(user.uid);
final savedUserId = await _sessionStorage.getUserId();
print('Saved and retrieved user ID: $savedUserId');
```

### **Verificar Firebase Auth:**

```dart
// Agregar en AuthRemoteDataSourceImpl
final currentUser = _auth.currentUser;
print('Firebase current user: ${currentUser?.uid}');
```

### **Verificar AppFlowBloc State:**

```dart
// Agregar en AppFlowBloc._onCheckAppFlow
print('AppFlowBloc state before emit: ${blocState.runtimeType}');
emit(blocState);
print('AppFlowBloc state after emit: ${state.runtimeType}');
```

## 📊 **Logs Esperados para Flujo Exitoso**

```
[AUTH_BLOC] Starting sign up process for email: test@example.com
[AUTH_BLOC] Sign up successful for new user: test@example.com (ID: abc123)
[AUTH_SCREEN] Auth successful! User: test@example.com (ID: abc123)
[AUTH_SCREEN] Triggering AppFlowBloc.checkAppFlow() after successful auth
[APP_FLOW_BLOC] Starting simplified app flow check
[APP_BOOTSTRAP] Starting simplified app initialization
[APP_BOOTSTRAP] Performing simple auth check...
[SESSION_SERVICE] Starting getCurrentSession()
[SESSION_SERVICE] Step 1: Checking authentication status...
[SESSION_SERVICE] Authentication check result: true
[SESSION_SERVICE] Step 2: Getting current user...
[SESSION_SERVICE] Current user retrieved: test@example.com (ID: abc123)
[SESSION_SERVICE] Step 3 & 4: Checking onboarding and profile completeness in parallel...
[SESSION_SERVICE] Onboarding completed: false
[SESSION_SERVICE] Profile completeness: false
[SESSION_SERVICE] User needs setup - onboarding: false, profile: false
[APP_BOOTSTRAP] Auth check completed: authenticated
[APP_BOOTSTRAP] App bootstrap completed successfully in 150ms
[APP_FLOW_BLOC] App flow check completed: Setup
[APP_ROUTER] Redirect called - flowState: AppFlowAuthenticated currentLocation: /auth
[NAVIGATION] NavigationService: Evaluating route for state AppFlowAuthenticated at location: /auth
[NAVIGATION] NavigationService: Handling authenticated state - needsOnboarding: true, needsProfileSetup: false at: /auth
[NAVIGATION] NavigationService: Redirecting to onboarding (needs onboarding)
[APP_ROUTER] Redirecting from /auth to /onboarding
```

## 🎯 **Próximos Pasos**

1. **Ejecuta la app** y reproduce el problema
2. **Copia todos los logs** relacionados con el flujo de auth
3. **Identifica dónde se rompe** el flujo usando esta guía
4. **Comparte los logs** para análisis específico
