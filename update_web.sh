#!/bin/bash
set -e

# Navegar al directorio del script (funciona desde cualquier directorio)
cd "$(dirname "$0")"

echo "=== Alexandria Web Deploy ==="

# Verificar que el build existe
if [ ! -f "web/main.dart.js" ]; then
    echo "ERROR: web/main.dart.js no encontrado. Ejecutar flutter build web --release primero."
    exit 1
fi

# 1. Corregir URL del API (localhost → producción)
echo "→ Corrigiendo URL del API en main.dart.js..."
sed -i 's|"http://localhost:8000"|"https://alexandria.voxl.com.co/api"|g' web/main.dart.js

OCURRENCIAS=$(grep -c "localhost:8000" web/main.dart.js || true)
if [ "$OCURRENCIAS" -ne 0 ]; then
    echo "ERROR: Todavía quedan $OCURRENCIAS ocurrencias de localhost:8000"
    exit 1
fi
echo "   ✓ URL corregida → https://alexandria.voxl.com.co/api"

# 2. Actualizar cache-buster en index.html
# El regex [^"]* maneja tanto la primera ejecución (sin ?v=)
# como ejecuciones posteriores (con ?v=fecha anterior)
echo "→ Actualizando cache-buster en index.html..."
FECHA=$(date +%Y%m%d)
sed -i "s|flutter_bootstrap\.js[^\"]*\"|flutter_bootstrap.js?v=${FECHA}a\"|g" web/index.html
echo "   ✓ Cache-buster → ?v=${FECHA}a"

# 3. Desplegar a nginx
echo "→ Sincronizando con nginx..."
rsync -a --delete --info=stats2 web/ /root/nginx/web/alexandria/
echo "   ✓ Sincronización completada"

echo ""
echo "=== Deploy finalizado ==="
grep "voxl.com.co/api" web/main.dart.js | head -1
grep "flutter_bootstrap.js" /root/nginx/web/alexandria/index.html
