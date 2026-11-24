#!/usr/bin/env bash
# Puerta de higiene antes de cada push y antes de la entrega.
# Uso:  bash scripts/check_entrega.sh          (higiene: secretos, artefactos, CRLF)
#       bash scripts/check_entrega.sh --final  (ademas: archivos obligatorios de la entrega)
# Sale 0 solo si todo esta bien. Revisa el arbol, el indice y TODO el historial,
# porque en un repo publico un secreto borrado sigue en los commits viejos.
set -u
cd "$(git rev-parse --show-toplevel)" || exit 2
fallos=0
mal() { echo "FALLO: $*"; fallos=$((fallos + 1)); }

# 1. Archivos que nunca van al repo: .env y, si existe, la lista local de cada
#    maquina en .git/info/prohibidos (una regex por linea; no se versiona).
prohibidos='(^|/)\.env$'
if [ -s .git/info/prohibidos ]; then
  prohibidos="$prohibidos|$(grep -v '^#' .git/info/prohibidos | grep . | paste -sd'|')"
fi
en_indice=$(git ls-files | grep -E "$prohibidos")
[ -n "$en_indice" ] && mal "archivos internos en el repo:"$'\n'"$en_indice"
en_historial=$(git log --all --name-only --format= | sort -u | grep -E "$prohibidos")
[ -n "$en_historial" ] && mal "archivos internos en el HISTORIAL (hay que reescribirlo):"$'\n'"$en_historial"

# 2. Secretos con forma reconocible, en el arbol y en el historial
patron='sk-ant-[A-Za-z0-9_-]{20,}|sk-(proj-)?[A-Za-z0-9_-]{32,}|hf_[A-Za-z0-9]{30,}|AIza[0-9A-Za-z_-]{35}|gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,}|nvapi-[A-Za-z0-9_-]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
arbol=$(git grep -nIE "$patron" -- . ':!scripts/check_entrega.sh' | cut -c1-120)
[ -n "$arbol" ] && mal "posible secreto en archivos versionados:"$'\n'"$arbol"
hist=$(git log --all -p --format='commit %h' -- . ':!scripts/check_entrega.sh' | grep -E "^\+.*($patron)" | cut -c1-80)
[ -n "$hist" ] && mal "posible secreto en el historial:"$'\n'"$hist"

# 3. .env.example solo con claves vacias
if [ -f .env.example ]; then
  llenas=$(grep -E '^[A-Z0-9_]*(KEY|TOKEN|SECRET|PASSWORD)[A-Z0-9_]*=.+' .env.example)
  [ -n "$llenas" ] && mal ".env.example trae valor en una variable secreta (debe ir vacia):"$'\n'"$llenas"
fi

# 4. Saltos de linea: nada en CRLF salvo scripts de Windows
crlf=$(git ls-files --eol | awk '$1=="i/crlf"' | grep -vE '\.(bat|cmd|ps1)$')
[ -n "$crlf" ] && mal "archivos con CRLF en el indice:"$'\n'"$crlf"

# 5. Archivos de la entrega (solo con --final)
if [ "${1:-}" = "--final" ]; then
  for f in README.md LICENSE; do
    [ -s "$f" ] || mal "falta o esta vacio: $f"
  done
  grep -q 'Entorno Python para hackathon' README.md 2>/dev/null && mal "README.md sigue siendo el de la plantilla"
  grep -qE 'https://' README.md 2>/dev/null || mal "README.md no enlaza demo, video ni deck (ninguna URL https)"
  [ -z "$(git status --porcelain)" ] || mal "hay cambios sin commitear"
fi

if [ "$fallos" -eq 0 ]; then echo "check_entrega: OK"; else echo "check_entrega: $fallos fallo(s)"; fi
[ "$fallos" -eq 0 ]
