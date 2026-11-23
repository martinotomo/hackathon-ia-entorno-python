# syntax=docker/dockerfile:1
# Entorno de desarrollo Python para hackathon.
# Misma imagen en Windows (Docker Desktop/WSL2) y Linux.
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Herramientas de sistema mínimas (compilación de wheels y git)
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential git curl \
    && rm -rf /var/lib/apt/lists/*

# Usuario no root con UID/GID configurables (evita archivos de root en Linux)
ARG UID=1000
ARG GID=1000
RUN groupadd --gid ${GID} dev \
    && useradd --uid ${UID} --gid ${GID} --create-home --shell /bin/bash dev

WORKDIR /app

# Dependencias primero para aprovechar la caché de capas
COPY requirements.txt .
# torch CPU-only primero: evita descargar ~3 GB de librerías CUDA.
# Para GPU, elimina esta línea y usa el torch de PyPI.
RUN pip install torch==2.15.0 --index-url https://download.pytorch.org/whl/cpu \
    && pip install -r requirements.txt

COPY --chown=dev:dev . .

USER dev
EXPOSE 8888 8000 8501

# Por defecto abre JupyterLab; sobrescribe el comando para otra cosa
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--ServerApp.token="]
