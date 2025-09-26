# 🎵 Cómo Consumir TrackContextBackgroundService

## **🎯 CASOS DE USO REALES**

### **1. 📱 Notificaciones de Reproducción (YA IMPLEMENTADO)**

En `AudioPlaybackServiceImpl`, ahora cada track que se reproduce automáticamente crea un `MediaItem` con información rica:

```dart
// ✅ AUTOMÁTICO - Ya funciona sin código adicional
// Cuando reproduces un track, la notificación muestra:
// - Título: "My Track"
// - Artista: "Admin" (del colaborador)
// - Álbum: "My Project" (nombre del proyecto)
// - Duración: "2:17" (de TrackVersion)
```

### **2. 🔒 Control desde Lock Screen**

Los controles del lock screen ahora muestran información completa:

```dart
// ✅ AUTOMÁTICO - Información rica en controles
// Lock screen muestra:
// - Play/Pause con info real del artista
// - Skip Next/Previous funcionando
// - Progress bar con duración correcta
```

### **3. 🚗 Android Auto / CarPlay**

Para integración con autos (futuro):

```dart
// En un servicio de Auto/CarPlay
final backgroundService = TrackContextBackgroundService.instance;

// Obtener info actual para mostrar en pantalla del auto
final trackInfo = await backgroundService.getCurrentContext();
if (trackInfo != null) {
  displayInCar(
    artist: trackInfo.collaborator?.name ?? 'Unknown',
    title: currentTrack.title,
    project: trackInfo.projectName,
  );
}
```

### **4. 📻 Widget de Escritorio (iOS 14+)**

Para widgets que muestran el track actual:

```dart
// En un widget provider
class MusicWidgetProvider {
  static Future<Map<String, String>> getCurrentTrackInfo() async {
    final service = TrackContextBackgroundService.instance;
    final context = service.getCurrentContext();
    
    return {
      'title': context?.trackTitle ?? 'No music',
      'artist': context?.collaborator?.name ?? '',
      'project': context?.projectName ?? '',
    };
  }
}
```

### **5. 🎧 Integración con Auriculares Bluetooth**

Para mostrar info en auriculares con pantalla:

```dart
// En un servicio de Bluetooth
class BluetoothAudioService {
  Future<void> sendTrackInfoToHeadphones() async {
    final service = TrackContextBackgroundService.instance;
    final context = await service.getCurrentContext();
    
    if (context != null) {
      // Enviar metadata a auriculares
      await bluetoothDevice.sendMetadata({
        'artist': context.collaborator?.name,
        'title': getCurrentTrackTitle(),
        'album': context.projectName,
        'duration': context.activeVersionDuration?.inSeconds,
      });
    }
  }
}
```

## **🛠️ TESTING EN PRÁCTICA**

### **Prueba la Implementación Actual:**

1. **Reproduce un track** en la app
2. **Envía la app a background** (botón home)
3. **Ve a la notification center** o lock screen
4. **Verifica que muestra:**
   - ✅ Artista correcto (no "Unknown")
   - ✅ Duración real (no 0:00)
   - ✅ Nombre del proyecto como álbum

### **Comportamiento Esperado:**

```
ANTES (sin TrackContextBackgroundService):
📱 "My Track"
🎤 "Unknown Artist"  ❌
⏱️ "0:00 / 0:00"    ❌
💿 ""               ❌

DESPUÉS (con TrackContextBackgroundService):
📱 "My Track"
🎤 "Admin"          ✅ (del colaborador real)
⏱️ "1:23 / 2:17"   ✅ (duración de TrackVersion)
💿 "My Project"     ✅ (nombre del proyecto)
```

## **⚡ VERIFICACIÓN RÁPIDA**

Ejecuta este código en cualquier parte de la app para verificar que funciona:

```dart
void _testBackgroundService() async {
  final service = TrackContextBackgroundService.instance;
  
  // Simular obtener info de un track específico
  final info = await service.getTrackInfoForBackground(
    'c504ca4c-7cbf-49d8-8ef1-04b709a71a8a', 
    'Test Track'
  );
  
  print('🎯 Artist: ${info.artist}');
  print('⏱️ Duration: ${info.duration}');
  print('💿 Project: ${info.projectName}');
  
  // Resultado esperado:
  // 🎯 Artist: Admin
  // ⏱️ Duration: 0:02:17.142000
  // 💿 Project: My Project
}
```

## **🔧 DEBUGGING**

Si algo no funciona, verifica:

1. **¿Se está cargando el contexto?**
   ```dart
   // Debe aparecer en logs cuando reproduces
   print('🎯 CONTEXT INFO: Artist: ${artist}, Duration: ${duration}');
   ```

2. **¿El cache está funcionando?**
   ```dart
   final cache = TrackContextBackgroundService.instance.getCurrentContext();
   print('💾 Cache: ${cache != null ? 'Active' : 'Empty'}');
   ```

3. **¿Los BloCs están sincronizados?**
   ```dart
   // AudioContextBloc debe actualizar el background service automáticamente
   ```

## **🚀 PRÓXIMOS PASOS**

1. **Widgets de iOS**: Usar el servicio para widgets de pantalla de inicio
2. **Android Auto**: Integración completa con Android Auto
3. **Wear OS**: Mostrar info en smartwatches
4. **Shortcuts de Siri**: "Oye Siri, ¿qué está sonando?"
5. **Integración con Last.fm**: Scrobbling automático con metadata rica
