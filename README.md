# Entorno Python para hackathon (Windows + Linux)

Mismo entorno en cualquier máquina usando Docker.

## Inicio rápido

```bash
cp .env.example .env        # en Windows PowerShell: Copy-Item .env.example .env
docker compose up --build
```

Abre JupyterLab en http://localhost:8888.

Shell dentro del contenedor: `docker compose run --rm dev bash`

## Contenido

| Archivo | Para qué sirve |
|---|---|
| `Dockerfile` | Imagen Python 3.12 con usuario no root |
| `requirements.txt` | Librerías base de IA con versiones fijadas |
| `docker-compose.yml` | Puertos, volumen y variables de entorno |
| `.gitattributes` | Fuerza LF en el repo (CRLF solo para .bat/.cmd/.ps1) |
| `.editorconfig` | Mismo estilo en cualquier editor |

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
