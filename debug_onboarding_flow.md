# 🔍 Debug Guide: Onboarding Flow Issue

## 🎯 **Problema**

Después de completar el onboarding y presionar "Get Started", la app se redirige de nuevo al onboarding en lugar de ir al dashboard.

## 📋 **Pasos para Debuggear**

### 1. **Ejecutar la app con logs detallados**

```bash
flutter run --debug
```

### 2. **Buscar estos logs específicos en orden:**

#### **A. Presionar "Get Started":**

```
[ONBOARDING_SCREEN] "Get Started" button pressed, triggering MarkOnboardingCompleted
[ONBOARDING_BLOC] Marking onboarding as completed
[ONBOARDING_BLOC] Got user ID for completion: [user_id]
[ONBOARDING_BLOC] Calling onboardingCompleted for user: [user_id]
[ONBOARDING_USECASE] Marking onboarding as completed for user: [user_id]
[ONBOARDING_REPOSITORY] Marking onboarding as completed for user: [user_id]
[ONBOARDING_DATASOURCE] Setting onboarding completed to true for user: [user_id]
[ONBOARDING_DATASOURCE] Using key: onboardingCompleted_[user_id]
[ONBOARDING_DATASOURCE] Saved value: true for key: onboardingCompleted_[user_id]
[ONBOARDING_REPOSITORY] Successfully marked onboarding as completed for user: [user_id]
[ONBOARDING_USECASE] Successfully marked onboarding as completed for user: [user_id]
[ONBOARDING_BLOC] Successfully marked onboarding as completed
[ONBOARDING_BLOC] Emitting OnboardingCompleted state
```

#### **B. OnboardingScreen recibe el estado:**

```
[ONBOARDING_SCREEN] Received state: OnboardingCompleted
[ONBOARDING_SCREEN] Onboarding completed, triggering AppFlowBloc.checkAppFlow()
```

#### **C. AppFlowBloc procesa el cambio:**

```
[APP_FLOW_BLOC] Starting simplified app flow check
[APP_BOOTSTRAP] Starting simplified app initialization
[SESSION_SERVICE] Step 1: Checking authentication status...
[SESSION_SERVICE] User is authenticated: [user_id]
[SESSION_SERVICE] Step 3 & 4: Checking onboarding and profile completeness in parallel...
[ONBOARDING_USECASE] Checking onboarding completed for user: [user_id]
[ONBOARDING_REPOSITORY] Checking onboarding completed for user: [user_id]
[ONBOARDING_DATASOURCE] Checking onboarding completed for user: [user_id]
[ONBOARDING_DATASOURCE] Using key: onboardingCompleted_[user_id]
[ONBOARDING_DATASOURCE] Retrieved value: true for key: onboardingCompleted_[user_id]
[ONBOARDING_REPOSITORY] Onboarding completed check result: true for user: [user_id]
[ONBOARDING_USECASE] Onboarding completed check result: true for user: [user_id]
[SESSION_SERVICE] Onboarding completed: true
[SESSION_SERVICE] Profile completeness: false
[SESSION_SERVICE] User needs setup - onboarding: true, profile: false
[APP_BOOTSTRAP] Auth check completed: authenticated
[APP_FLOW_BLOC] App flow check completed: Setup
```

#### **D. NavigationService decide la ruta:**

```
[NAVIGATION] NavigationService: Evaluating route for state AppFlowAuthenticated at location: /onboarding
[NAVIGATION] NavigationService: Handling authenticated state - needsOnboarding: false, needsProfileSetup: true at: /onboarding
[NAVIGATION] NavigationService: Redirecting to profile creation (needs profile setup)
[APP_ROUTER] AppRouter: Redirect called - flowState: AppFlowAuthenticated, currentLocation: /onboarding
[APP_ROUTER] AppRouter: Redirecting to /profile-creation
```

## 🔍 **Posibles Problemas:**

### **1. Onboarding no se guarda correctamente**

- Buscar logs de error en `[ONBOARDING_DATASOURCE]`
- Verificar que el valor se guarde como `true`

### **2. SessionService no detecta el cambio**

- Buscar logs de `[SESSION_SERVICE]` que muestren `onboarding: false`
- Verificar que el `CheckOnboardingCompletedUseCase` retorne `true`

### **3. NavigationService no redirige correctamente**

- Buscar logs de `[NAVIGATION]` que muestren decisiones incorrectas
- Verificar que `needsOnboarding: false` y `needsProfileSetup: true`

### **4. AppFlowBloc no mapea correctamente**

- Buscar logs de `[APP_FLOW_BLOC]` que muestren mapeo incorrecto
- Verificar que `AppInitialState.setup` se mapee a `AppFlowAuthenticated`

## 🎯 **Logs Esperados Después de la Corrección:**

```
[ONBOARDING_SCREEN] "Get Started" button pressed, triggering MarkOnboardingCompleted
[ONBOARDING_BLOC] Marking onboarding as completed
[ONBOARDING_BLOC] Successfully marked onboarding as completed
[ONBOARDING_SCREEN] Onboarding completed, triggering AppFlowBloc.checkAppFlow()
[APP_FLOW_BLOC] Starting simplified app flow check
[SESSION_SERVICE] Onboarding completed: true
[SESSION_SERVICE] Profile completeness: false
[SESSION_SERVICE] User needs setup - onboarding: true, profile: false
[APP_BOOTSTRAP] Auth check completed: authenticated
[APP_FLOW_BLOC] App flow check completed: Setup
[NAVIGATION] NavigationService: Redirecting to profile creation (needs profile setup)
[APP_ROUTER] AppRouter: Redirecting to /profile-creation
```

## 🚨 **Si el problema persiste:**

1. **Verificar SharedPreferences** - Los datos podrían no estar guardándose
2. **Verificar User ID** - Podría estar usando un ID incorrecto
3. **Verificar Profile Completeness** - El usuario podría necesitar completar su perfil
4. **Verificar Navigation Logic** - La lógica de redirección podría estar mal

## 📝 **Comandos útiles:**

```bash
# Limpiar SharedPreferences para testing
flutter run --debug --dart-define=clear_prefs=true

# Ver logs específicos
flutter logs | grep -E "(ONBOARDING|SESSION|NAVIGATION|APP_FLOW)"
```
