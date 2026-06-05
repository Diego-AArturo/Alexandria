# Alexandria - notas para reemplazar la carpeta web

Este documento resume los puntos que NO se deben perder cuando se vuelva a publicar o reemplazar `web/`.

## 1) Base URL del frontend

El build web debe consumir la API por ruta relativa:

- Correcto: `/api`
- Incorrecto: `http://localhost:8000`

Si vuelve a aparecer `localhost`, los usuarios veran errores de CORS y fallos de login/register.

Verificacion rapida:

```bash
grep -n "localhost:8000\|http://localhost" /root/alexandria/web/main.dart.js
```

Debe no devolver resultados.

## 2) Nginx proxy de API

El dominio publico debe usar el proxy:

- `/api/*` -> `http://alexandria_api:8000/*`

Archivo de referencia:

- `/root/nginx/conf.d/alexandria-web.conf`

Despues de cambios en ese archivo:

```bash
docker exec nginx_reverse_proxy nginx -t
docker exec nginx_reverse_proxy nginx -s reload
```

## 3) Cache: evitar que clientes queden con JS viejo

Al reemplazar `web/`, revisar que Nginx no deje cache fuerte para estos archivos:

- `main.dart.js`
- `flutter_bootstrap.js`
- `index.html`
- `flutter_service_worker.js`

Actualmente se fuerza `Cache-Control: no-cache` para archivos criticos.

## 4) Service Worker

Para evitar servir bundles viejos desde cache del navegador, validar el bootstrap:

- En `flutter_bootstrap.js`, `serviceWorkerSettings` debe estar en `null` (segun el ajuste actual).

Si se regenera el build de Flutter, este cambio se puede perder.

## 5) Cache busting del bootstrap

En `index.html` se usa version en query string del bootstrap (ejemplo):

- `flutter_bootstrap.js?v=20260429a`

Si reemplazas `web/`, actualiza este valor para forzar descarga del script nuevo.

## 6) Flujo recomendado al publicar nueva carpeta web

1. Copiar nueva carpeta `web/` al destino servido por Nginx.
2. Verificar que `main.dart.js` no tenga `localhost`.
3. Verificar que `index.html` tenga version en `flutter_bootstrap.js?v=...`.
4. Verificar reglas de cache en `alexandria-web.conf`.
5. Recargar Nginx (`nginx -t` y `nginx -s reload`).
6. Probar en modo incognito:
   - `https://alexandria.voxl.com.co/api/health`
   - login y register desde UI.

## 7) Pruebas utiles

Preflight CORS:

```bash
curl -i -X OPTIONS "https://alexandria.voxl.com.co/api/auth/login" \
  -H "Origin: https://alexandria.voxl.com.co" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: content-type"
```

Login:

```bash
curl -i -X POST "https://alexandria.voxl.com.co/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"12345678"}'
```

Si aparece 500 en auth, revisar conexion API <-> Postgres (credenciales del usuario `postgres`).
