# 🔧 Comandos para Reiniciar Alexandria Correctamente

## Opción 1: Script Automático (RECOMENDADO)

```bash
cd /root/alexandria/backend
chmod +x REINICIAR_ALEXANDRIA.sh
./REINICIAR_ALEXANDRIA.sh
```

---

## Opción 2: Comandos Manuales Paso a Paso

### 1. Detener y Limpiar Contenedores Antiguos

```bash
cd /root/alexandria/backend

# Detener contenedores
docker stop alexandria_api alexandria_db 2>/dev/null || true

# Eliminar contenedores
docker rm -f alexandria_api alexandria_db 2>/dev/null || true

# Limpiar cualquier contenedor huérfano de Alexandria
docker ps -a | grep alexandria | awk '{print $1}' | xargs -r docker rm -f 2>/dev/null || true
```

### 2. Reconstruir Imagen

```bash
# Reconstruir desde cero (toma 2-3 minutos)
docker-compose build --no-cache api
```

### 3. Iniciar Servicios

```bash
# Levantar contenedores
docker-compose up -d

# Esperar 15 segundos para inicialización
sleep 15
```

### 4. Verificar Estado

```bash
# Ver estado de contenedores
docker ps | grep alexandria

# Verificar variables de entorno de CrewAI
docker exec alexandria_api env | grep -E "CREWAI|OTEL"

# Ver conexiones a BD
docker exec alexandria_db psql -U postgres -d alexandria -c \
  "SELECT count(*) as total, state FROM pg_stat_activity WHERE datname='alexandria' GROUP BY state;"

# Probar health check
curl http://localhost:8000/health
```

### 5. Monitorear Logs

```bash
# Ver logs en vivo
docker logs -f alexandria_api

# Ver solo errores
docker logs alexandria_api 2>&1 | grep -i "error\|exception"

# Ver logs sin healthchecks
docker logs alexandria_api 2>&1 | grep -v "GET /health"
```

---

## Solución Rápida al Error 'ContainerConfig'

Si ves este error al hacer `docker-compose up -d`:

```
KeyError: 'ContainerConfig'
```

**Solución:**
```bash
# Eliminar el contenedor corrupto
docker rm -f alexandria_api

# Intentar de nuevo
docker-compose up -d
```

---

## Verificación Post-Reinicio

✅ **Checklist de verificación:**

1. **Contenedores healthy:**
   ```bash
   docker ps | grep alexandria
   # Debe mostrar "healthy" en ambos
   ```

2. **Variables de CrewAI aplicadas:**
   ```bash
   docker exec alexandria_api env | grep CREWAI_TELEMETRY
   # Debe mostrar: CREWAI_TELEMETRY=false
   ```

3. **API responde:**
   ```bash
   curl http://localhost:8000/health
   # Debe mostrar: {"status":"ok"}
   ```

4. **Sin prompts interactivos:**
   ```bash
   docker logs alexandria_api 2>&1 | grep -i "would you like"
   # No debe mostrar nada
   ```

5. **Conexiones BD estables:**
   ```bash
   docker exec alexandria_db psql -U postgres -d alexandria -c \
     "SELECT count(*), state FROM pg_stat_activity WHERE datname='alexandria' GROUP BY state;"
   # Debe mostrar conexiones bajas (1-5)
   ```

---

## Troubleshooting Común

### Problema: "Connection refused" al inicio

**Causa:** PostgreSQL tarda en iniciar

**Solución:**
```bash
# Esperar 30 segundos adicionales
sleep 30

# Verificar BD
docker logs alexandria_db | tail -20
```

### Problema: Error 500 en /api/auth/register

**Causa:** Pool de conexiones sin configurar o BD no lista

**Solución:**
```bash
# Verificar que la BD está lista
docker exec alexandria_db pg_isready -U postgres

# Reiniciar API
docker-compose restart api

# Verificar logs
docker logs alexandria_api --tail 50
```

### Problema: Contenedor se queda en "starting"

**Causa:** Healthcheck fallando

**Solución:**
```bash
# Ver detalles del healthcheck
docker inspect alexandria_api --format='{{json .State.Health}}' | python3 -m json.tool

# Ver logs del contenedor
docker logs alexandria_api
```

---

## Comandos de Monitoreo Continuo

### Ver recursos en tiempo real
```bash
docker stats alexandria_api alexandria_db
```

### Ver logs en tiempo real sin healthchecks
```bash
docker logs -f alexandria_api 2>&1 | grep -v "GET /health"
```

### Ver conexiones activas a BD
```bash
watch -n 5 'docker exec alexandria_db psql -U postgres -d alexandria -c "SELECT count(*), state FROM pg_stat_activity WHERE datname=\"alexandria\" GROUP BY state;"'
```

---

## Si Todo Falla: Reset Completo

**⚠️ Esto eliminará TODOS los datos de Alexandria:**

```bash
cd /root/alexandria/backend

# Detener y eliminar todo
docker-compose down -v

# Eliminar volúmenes
docker volume rm pgdata_alexandria 2>/dev/null || true

# Reconstruir desde cero
docker-compose build --no-cache

# Iniciar limpio
docker-compose up -d

# Esperar e inicializar BD
sleep 30
```

**Nota:** Después del reset completo, necesitarás recrear usuarios y datos.

---

## Resumen de Archivos Modificados

✅ Archivos con configuración optimizada:

1. `/root/alexandria/backend/src/models/database.py`
   - Pool de conexiones con keepalives TCP
   - `pool_recycle=1800` (30 min)
   - `pool_pre_ping=True`

2. `/root/alexandria/backend/src/agents/execution_limits.py`
   - Crews en modo no-verboso
   - Sin memoria ni embedder

3. `/root/alexandria/backend/docker-compose.yml`
   - Variables CREWAI_TELEMETRY, CREWAI_TRACE_ENABLED, OTEL_SDK_DISABLED
   - Healthcheck más tolerante
   - Montaje de postgresql.conf

4. `/root/alexandria/backend/Dockerfile`
   - Timeouts extendidos en Uvicorn
   - Límite de concurrencia

5. `/root/alexandria/backend/database/postgresql.conf` (nuevo)
   - TCP keepalives para PostgreSQL
   - Timeouts de sesiones

---

**Fecha:** 3 de Junio, 2026  
**Autor:** GitHub Copilot  
**Versión:** 1.0
