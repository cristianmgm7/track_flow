#!/bin/bash

# Script para verificar y corregir los bundle IDs en iOS
# Uso: ./scripts/fix_ios_bundle_ids.sh

echo "🔍 Verificando y corrigiendo bundle IDs en iOS..."
echo "================================================"

cd ios

# Verificar que los archivos xcconfig tengan los bundle IDs correctos
echo "📋 Verificando bundle IDs en archivos xcconfig..."

# Verificar archivos en el directorio ios/
echo "Archivos en directorio ios/:"
if grep -q "com.crd.producer-gmail.com.trackflow.dev" Debug.xcconfig; then
    echo "✅ Debug.xcconfig: com.crd.producer-gmail.com.trackflow.dev"
else
    echo "❌ Debug.xcconfig: bundle ID incorrecto"
fi

if grep -q "com.crd.producer-gmail.com.trackflow.staging" "Debug 2.xcconfig"; then
    echo "✅ Debug 2.xcconfig: com.crd.producer-gmail.com.trackflow.staging"
else
    echo "❌ Debug 2.xcconfig: bundle ID incorrecto"
fi

if grep -q "com.crd.producer-gmail.com.trackflow" "Debug 3.xcconfig"; then
    echo "✅ Debug 3.xcconfig: com.crd.producer-gmail.com.trackflow"
else
    echo "❌ Debug 3.xcconfig: bundle ID incorrecto"
fi

# Verificar archivos en el directorio config/
echo ""
echo "Archivos en directorio config/:"
if grep -q "com.crd.producer-gmail.com.trackflow.dev" config/development/Debug.xcconfig; then
    echo "✅ config/development/Debug.xcconfig: com.crd.producer-gmail.com.trackflow.dev"
else
    echo "❌ config/development/Debug.xcconfig: bundle ID incorrecto"
fi

if grep -q "com.crd.producer-gmail.com.trackflow.staging" config/staging/Debug.xcconfig; then
    echo "✅ config/staging/Debug.xcconfig: com.crd.producer-gmail.com.trackflow.staging"
else
    echo "❌ config/staging/Debug.xcconfig: bundle ID incorrecto"
fi

if grep -q "com.crd.producer-gmail.com.trackflow" config/production/Debug.xcconfig; then
    echo "✅ config/production/Debug.xcconfig: com.crd.producer-gmail.com.trackflow"
else
    echo "❌ config/production/Debug.xcconfig: bundle ID incorrecto"
fi

echo ""
echo "🔧 Verificando configuraciones de Xcode..."

# Verificar configuraciones específicas
configs=("Debug develop" "Debug staging" "Debug prod" "Release develop" "Release staging" "Release prod")

for config in "${configs[@]}"; do
    echo "Verificando $config..."
    bundle_id=$(xcodebuild -showBuildSettings -configuration "$config" | grep PRODUCT_BUNDLE_IDENTIFIER | awk -F' = ' '{print $2}' | tr -d ' ')
    
    case $config in
        *"develop"*)
            expected="com.crd.producer-gmail.com.trackflow.dev"
            ;;
        *"staging"*)
            expected="com.crd.producer-gmail.com.trackflow.staging"
            ;;
        *"prod"*)
            expected="com.crd.producer-gmail.com.trackflow"
            ;;
        *)
            expected="unknown"
            ;;
    esac
    
    if [ "$bundle_id" = "$expected" ]; then
        echo "✅ $config: $bundle_id"
    else
        echo "❌ $config: $bundle_id (esperado: $expected)"
    fi
done

echo ""
echo "📝 Próximos pasos si hay problemas:"
echo "1. Verifica que los archivos xcconfig estén referenciados correctamente en Xcode"
echo "2. Asegúrate de que los archivos xcconfig contengan los bundle IDs correctos"
echo "3. Limpia el proyecto: Product > Clean Build Folder"
echo "4. Reinicia Xcode" 