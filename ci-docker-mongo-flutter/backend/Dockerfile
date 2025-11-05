FROM python:3.12-slim

# Evita prompts interactivos y reduce capa de apt
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Dependencias del sistema SOLO si quieres usar curl en el healthcheck (opción A)
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

# Instala dependencias de Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia el código
COPY . .

EXPOSE 8000

# Arranque de Uvicorn (asegúrate que tu app esté en main.py con objeto FastAPI = app)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]