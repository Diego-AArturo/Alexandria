FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias de sistema necesarias y limpiar cache
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libpq-dev build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements e instalarlos
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copiar el código completo de la aplicación
COPY . /app

# Aumentar timeouts para procesos largos de generación de cursos con LLM
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--log-level", "info", "--timeout-keep-alive", "120", "--limit-concurrency", "50"]
