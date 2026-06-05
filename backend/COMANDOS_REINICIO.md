# 🔧 Comandos para Reiniciar Alexandria Correctamente

## Opción 1: Script Automático (RECOMENDADO)

```bash

cd/root/alexandria/backend

chmod+xREINICIAR_ALEXANDRIA.sh

./REINICIAR_ALEXANDRIA.sh

```

---

## Opción 2: Comandos Manuales Paso a Paso

### 1. Detener y Limpiar Contenedores Antiguos

```bash

cd/root/alexandria/backend


# Detener contenedores

dockerstopalexandria_apialexandria_db 2>/dev/null || true


# Eliminar contenedores

dockerrm-falexandria_apialexandria_db 2>/dev/null || true


# Limpiar cualquier contenedor huérfano de Alexandria

dockerps-a | grepalexandria | awk'{print $1}' | xargs-rdockerrm-f 2>/dev/null || true

```

### 2. Reconstruir Imagen

```bash

# Reconstruir desde cero (toma 2-3 minutos)

docker-composebuild--no-cacheapi

```

### 3. Iniciar Servicios

```bash

# Levantar contenedores

docker-composeup-d


# Esperar 15 segundos para inicialización

sleep15

```

### 4. Verificar Estado

```bash

# Ver estado de contenedores

dockerps | grepalexandria


# Verificar variables de entorno de CrewAI

dockerexecalexandria_apienv | grep-E"CREWAI|OTEL"


# Ver conexiones a BD

dockerexecalexandria_dbpsql-Upostgres-dalexandria-c\

  "SELECT count(*) as total, state FROM pg_stat_activity WHERE datname='alexandria' GROUP BY state;"


# Probar health check

curlhttp://localhost:8000/health

```

### 5. Monitorear Logs

```bash

# Ver logs en vivo

dockerlogs-falexandria_api


# Ver solo errores

dockerlogsalexandria_api 2>&1 | grep-i"error\|exception"


# Ver logs sin healthchecks

dockerlogsalexandria_api 2>&1 | grep-v"GET /health"

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

dockerrm-falexandria_api


# Intentar de nuevo

docker-composeup-d

```

---

## Verificación Post-Reinicio

✅ **Checklist de verificación:**

1.**Contenedores healthy:**

```bash

   docker ps | grepalexandria

   # Debe mostrar "healthy" en ambos

```

2.**Variables de CrewAI aplicadas:**

```bash

   docker exec alexandria_api env | grepCREWAI_TELEMETRY

   # Debe mostrar: CREWAI_TELEMETRY=false

```

3.**API responde:**

```bash

   curl http://localhost:8000/health

   # Debe mostrar: {"status":"ok"}

```

4.**Sin prompts interactivos:**

```bash

   docker logs alexandria_api 2>&1 | grep-i"would you like"

   # No debe mostrar nada

```

5.**Conexiones BD estables:**

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

sleep30


# Verificar BD

dockerlogsalexandria_db | tail-20

```

### Problema: Error 500 en /api/auth/register

**Causa:** Pool de conexiones sin configurar o BD no lista

**Solución:**

```bash

# Verificar que la BD está lista

dockerexecalexandria_dbpg_isready-Upostgres


# Reiniciar API

docker-composerestartapi


# Verificar logs

dockerlogsalexandria_api--tail50

```

### Problema: Contenedor se queda en "starting"

**Causa:** Healthcheck fallando

**Solución:**

```bash

# Ver detalles del healthcheck

dockerinspectalexandria_api--format='{{json .State.Health}}' | python3-mjson.tool


# Ver logs del contenedor

dockerlogsalexandria_api

```

---

## Comandos de Monitoreo Continuo

### Ver recursos en tiempo real

```bash

dockerstatsalexandria_apialexandria_db

```

### Ver logs en tiempo real sin healthchecks

```bash

dockerlogs-falexandria_api 2>&1 | grep-v"GET /health"

```

### Ver conexiones activas a BD

```bash

watch-n5'docker exec alexandria_db psql -U postgres -d alexandria -c "SELECT count(*), state FROM pg_stat_activity WHERE datname=\"alexandria\" GROUP BY state;"'

```

---

## Si Todo Falla: Reset Completo

**⚠️ Esto eliminará TODOS los datos de Alexandria:**

```bash

cd/root/alexandria/backend


# Detener y eliminar todo

docker-composedown-v


# Eliminar volúmenes

dockervolumermpgdata_alexandria 2>/dev/null || true


# Reconstruir desde cero

docker-composebuild--no-cache


# Iniciar limpio

docker-composeup-d


# Esperar e inicializar BD

sleep30

```

**Nota:** Después del reset completo, necesitarás recrear usuarios y datos.

---

## Resumen de Archivos Modificados

✅ Archivos con configuración optimizada:

1.`/root/alexandria/backend/src/models/database.py`

- Pool de conexiones con keepalives TCP

   -`pool_recycle=1800` (30 min)

   -`pool_pre_ping=True`

2.`/root/alexandria/backend/src/agents/execution_limits.py`

- Crews en modo no-verboso
- Sin memoria ni embedder

3.`/root/alexandria/backend/docker-compose.yml`

- Variables CREWAI_TELEMETRY, CREWAI_TRACE_ENABLED, OTEL_SDK_DISABLED
- Healthcheck más tolerante
- Montaje de postgresql.conf

4.`/root/alexandria/backend/Dockerfile`

- Timeouts extendidos en Uvicorn
- Límite de concurrencia

5.`/root/alexandria/backend/database/postgresql.conf` (nuevo)

- TCP keepalives para PostgreSQL
- Timeouts de sesiones

---

**Fecha:** 3 de Junio, 2026

**Autor:** GitHub Copilot

**Versión:** 1.0
