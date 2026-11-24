# Entorno Python para hackathon (Windows + Linux)

Mismo entorno en cualquier máquina usando Docker.

## Inicio rápido

```bash
cp .env.example .env        # en Windows PowerShell: Copy-Item .env.example .env
docker compose up --build
```

Abre JupyterLab en http://localhost:8888 (sin token: por eso los puertos solo escuchan
en `127.0.0.1`; no los abras a la red).

| Para | Comando |
|---|---|
| Shell en el contenedor | `docker compose run --rm dev bash` |
| Tests | `docker compose run --rm dev pytest -q` |
| Lint / formato | `docker compose run --rm dev ruff check .` · `ruff format .` |
| API FastAPI (`app/main.py` con `app`) | `docker compose run --rm --service-ports dev uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload` |
| Demo Streamlit | `docker compose run --rm --service-ports dev streamlit run app/ui.py --server.address=0.0.0.0` |
| Higiene antes de `push` | `bash scripts/check_entrega.sh` (y `--final` antes de entregar) |

### Linux con Podman en vez de Docker

Podman rootless monta la carpeta como `root` dentro del contenedor y el usuario `dev`
no puede escribir (no se guardan notebooks, falla `ruff --fix`). Se arregla con
`keep-id`, una vez por máquina:

```bash
mkdir -p ~/.config/containers
printf '[containers]\nuserns = "keep-id"\n' >> ~/.config/containers/containers.conf
```

o por comando: `PODMAN_USERNS=keep-id podman-compose up --build`. Con Docker (Windows,
Mac o Linux) no hace falta nada.

## Contenido

| Archivo | Para qué sirve |
|---|---|
| `Dockerfile` | Imagen Python 3.12 con usuario no root |
| `requirements.txt` | Librerías base de IA con versiones fijadas |
| `docker-compose.yml` | Puertos, volumen y variables de entorno |
| `.gitattributes` | Fuerza LF en el repo (CRLF solo para .bat/.cmd/.ps1) |
| `.editorconfig` | Mismo estilo en cualquier editor |
| `pyproject.toml` | Configuración de pytest y ruff |
| `scripts/check_entrega.sh` | Bloquea secretos, artefactos internos y CRLF antes de publicar |

## Saltos de línea: buenas prácticas

1. **`.gitattributes` es la fuente de verdad.** `* text=auto eol=lf` normaliza todo a LF sin importar el SO, así no aparecen modificaciones fantasma en el historial.
2. **Scripts de shell y Dockerfile siempre en LF.** Con CRLF fallan con `/bin/bash^M: bad interpreter`.
3. **`.editorconfig`** hace que VS Code, PyCharm, etc. guarden con LF.
4. **VS Code en Windows:** pon `"files.eol": "\n"` en la configuración.
5. **Git en Windows:** el `.gitattributes` manda sobre `core.autocrlf`. Recomendado: `git config core.autocrlf false`.
6. **Clona el repo dentro de WSL2** (`~/proyectos`) para mejor rendimiento de Docker en Windows.
7. **Si ya había archivos con CRLF**, renormaliza una vez:
   ```bash
   git add --renormalize .
   git commit -m "Normalizar saltos de línea a LF"
   ```
