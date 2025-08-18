# 📚 TrackFlow - Documentación Completa

Esta carpeta contiene toda la documentación necesaria para desarrollar, construir y distribuir TrackFlow.

## 📂 **Estructura de Documentación**

```
docs/
├── README.md                           # Este archivo - Índice principal
├── LAUNCH_CHECKLIST.md                 # ✅ Checklist de lanzamiento
├── COMANDOS_RAPIDOS.md                 # ⚡ Comandos más usados
├── development/                        # 🔧 Documentación de desarrollo
│   └── FIREBASE_PASO_A_PASO.md        # 🔥 Configuración Firebase (referencia)
├── distribution/                       # 📱 Distribución y lanzamiento
│   └── GUIA_TIENDAS_APLICACIONES.md   # 🏪 Guía para Google Play + App Store
├── workflows/                          # 🤖 Automatización
│   ├── README.md
│   ├── QUICK_START_GUIDE.md
│   └── GITHUB_ACTIONS_GUIDE.md
└── _archive/                           # 📦 Documentos legacy
    ├── RESUMEN_COMPLETO.md
    ├── LO_QUE_HICIMOS.md
    ├── WORKFLOW_AUTOMATIZADO.md
    ├── GUIA_GITHUB_ACTIONS.md
    └── ios_app_icons_setup.md
```

---

## 🚀 **INICIO RÁPIDO**

### Para desarrolladores nuevos:

1. 🚀 Lee [`workflows/README.md`](workflows/README.md) - Visión general de CI/CD
2. ⚡ Usa [`COMANDOS_RAPIDOS.md`](COMANDOS_RAPIDOS.md) - Comandos esenciales diarios
3. ✅ Revisa [`LAUNCH_CHECKLIST.md`](LAUNCH_CHECKLIST.md) - Para preparar releases

### Para configurar desde cero:

1. 🔥 Sigue [`development/FIREBASE_PASO_A_PASO.md`](development/FIREBASE_PASO_A_PASO.md)
2. 🤖 Revisa [`workflows/GITHUB_ACTIONS_GUIDE.md`](workflows/GITHUB_ACTIONS_GUIDE.md)

### Para lanzar a producción:

1. ✅ Sigue [`LAUNCH_CHECKLIST.md`](LAUNCH_CHECKLIST.md)
2. 📱 Usa [`distribution/GUIA_TIENDAS_APLICACIONES.md`](distribution/GUIA_TIENDAS_APLICACIONES.md)

---

## 🎯 **DOCUMENTOS POR PROPÓSITO**

### 🔧 **Desarrollo Diario**

- [`COMANDOS_RAPIDOS.md`](COMANDOS_RAPIDOS.md) - Comandos que usas todo el tiempo
- [`development/`](development/) - Setup y configuración de desarrollo

### 📱 **Testing y Distribución**

- [`workflows/GUIA_GITHUB_ACTIONS.md`](workflows/GUIA_GITHUB_ACTIONS.md) - Automatización completa
- [`distribution/`](distribution/) - Preparación para tiendas

### 📚 **Documentación Legacy**

- [`_archive/RESUMEN_COMPLETO.md`](_archive/RESUMEN_COMPLETO.md)
- [`_archive/LO_QUE_HICIMOS.md`](_archive/LO_QUE_HICIMOS.md)
- [`_archive/WORKFLOW_AUTOMATIZADO.md`](_archive/WORKFLOW_AUTOMATIZADO.md)

---

## 🆘 **¿DÓNDE ENCONTRAR LO QUE NECESITO?**

### "¿Cómo ejecuto la app?"

👉 [`COMANDOS_RAPIDOS.md`](COMANDOS_RAPIDOS.md) - Sección "Comandos de Desarrollo"

### "¿Cómo funciona Firebase?"

👉 [`development/FIREBASE_PASO_A_PASO.md`](development/FIREBASE_PASO_A_PASO.md)

### "¿Cómo configuro GitHub Actions?"

👉 [`workflows/GUIA_GITHUB_ACTIONS.md`](workflows/GUIA_GITHUB_ACTIONS.md)

### "¿Cómo funciona la automatización?"

👉 [`WORKFLOW_AUTOMATIZADO.md`](WORKFLOW_AUTOMATIZADO.md)

### "¿Cómo subo la app a las tiendas?"

👉 [`distribution/GUIA_TIENDAS_APLICACIONES.md`](distribution/GUIA_TIENDAS_APLICACIONES.md)

### "¿Qué hicimos y por qué?"

👉 [`RESUMEN_COMPLETO.md`](RESUMEN_COMPLETO.md)

### "¿Qué configuramos exactamente?"

👉 [`LO_QUE_HICIMOS.md`](LO_QUE_HICIMOS.md)

---

## 🏗️ **ARQUITECTURA DEL PROYECTO**

TrackFlow está construido con:

- **Flutter** - Framework principal
- **Clean Architecture + DDD** - Estructura del código
- **Firebase** - Backend (Auth, Firestore, Storage)
- **BLoC** - Gestión de estado
- **3 Flavors** - Development, Staging, Production
- **GitHub Actions** - CI/CD automático

---

## 👥 **PARA EL EQUIPO**

### Desarrolladores:

- Lean [`RESUMEN_COMPLETO.md`](RESUMEN_COMPLETO.md) para contexto
- Usen [`COMANDOS_RAPIDOS.md`](COMANDOS_RAPIDOS.md) diariamente

### QA/Testers:

- Reciben builds automáticamente vía Firebase App Distribution
- Instrucciones en [`workflows/GUIA_GITHUB_ACTIONS.md`](workflows/GUIA_GITHUB_ACTIONS.md)

### Product Manager:

- Proceso de releases en [`distribution/GUIA_TIENDAS_APLICACIONES.md`](distribution/GUIA_TIENDAS_APLICACIONES.md)

---

## 📞 **SOPORTE**

Si algo no funciona o tienes preguntas:

1. 🔍 Busca en la documentación correspondiente
2. 🐛 Revisa los logs de GitHub Actions
3. 🔥 Verifica la configuración de Firebase
4. 📱 Confirma que los flavors estén correctos

---

**💡 Consejo:** Mantén esta documentación actualizada conforme el proyecto evoluciona.
