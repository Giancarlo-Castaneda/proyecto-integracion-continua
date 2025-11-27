FROM python:3.10-slim
# ENVIRONMENT VARIABLES
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app


# 1. INSTALACIÓN DE HERRAMIENTAS DE SISTEMA Y COMPILACIÓ
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 2. COPIAR Y INSTALAR DEPENDENCIAS
COPY requirements.txt .

# Luego ejecuta el comando de instalación de pip.
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 3. COPIA EL CÓDIGO DE LA APLICACIÓN
COPY . .

EXPOSE 8000

# 4. COMANDO DE ARRANQUE (Ajusta si tu app principal no es main:app)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]