#!/bin/bash
# Script para reiniciar Alexandria Backend limpiamente
# Creado: 3 de Junio, 2026

set -e  # Detener si hay error

echo "=================================================="
echo "  REINICIO COMPLETO DE ALEXANDRIA BACKEND"
echo "=================================================="
echo ""

cd /root/alexandria/backend

echo "1. Deteniendo contenedores existentes..."
docker stop alexandria_api alexandria_db 2>/dev/null || true

echo "2. Eliminando contenedores antiguos..."
docker rm -f alexandria_api alexandria_db 2>/dev/null || true

echo "3. Limpiando contenedores huérfanos..."
docker ps -a | grep alexandria | awk '{print $1}' | xargs -r docker rm -f 2>/dev/null || true

echo "4. Reconstruyendo imagen de Alexandria (puede tomar 2-3 minutos)..."
docker-compose build --no-cache api

echo "5. Iniciando servicios..."
docker-compose up -d

echo ""
echo "6. Esperando inicialización (15 segundos)..."
sleep 15

echo ""
echo "=================================================="
echo "  VERIFICACIÓN DE ESTADO"
echo "=================================================="
echo ""

echo "Estado de contenedores:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "NAMES|alexandria"

echo ""
echo "Variables de CrewAI aplicadas:"
docker exec alexandria_api env | grep -E "CREWAI|OTEL" || echo "  ⚠️  Variables no encontradas"

echo ""
echo "Conexiones a BD:"
docker exec alexandria_db psql -U postgres -d alexandria -c "SELECT count(*) as total, state FROM pg_stat_activity WHERE datname='alexandria' GROUP BY state;"

echo ""
echo "Health check:"
curl -s http://localhost:8000/health || echo "  ⚠️  Health check falló"

echo ""
echo "=================================================="
echo "  REINICIO COMPLETADO"
echo "=================================================="
echo ""
echo "Monitorear logs con:"
echo "  docker logs -f alexandria_api"
echo ""