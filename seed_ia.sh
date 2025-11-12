#!/usr/bin/env bash
# seed_ai.sh — Genera datos con IA (descripciones) y embeddings para el recomendador.
# Requiere: OPENAI_API_KEY en .env
# Uso:
#   chmod +x seed_ai.sh
#   ./seed_ai.sh
# Flags:
#   --titles-file seed_titles.txt   # opcional: leer títulos desde un archivo (uno por línea)
#   --batch 20                      # tamaño de lote para evitar prompts muy largos (default 20)

set -euo pipefail

TITLES_FILE=""
BATCH_SIZE=20

while [[ $# -gt 0 ]]; do
  case "$1" in
    --titles-file) TITLES_FILE="${2:-}"; shift 2 ;;
    --batch) BATCH_SIZE="${2:-20}"; shift 2 ;;
    *) echo "Flag no reconocido: $1"; exit 1 ;;
  esac
done

info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { error "No se encontró '$1'. Instálalo y reintenta."; exit 1; }
}

# Lee OPENAI_API_KEY de .env
need_openai_key() {
  if [[ ! -f ".env" ]]; then
    error "No existe .env. Primero corre ./setup_local.sh"
    exit 1
  fi
  OA_KEY=$(grep -E '^OPENAI_API_KEY=' .env | cut -d'=' -f2- | tr -d '"')
  if [[ -z "${OA_KEY}" ]]; then
    error "OPENAI_API_KEY vacío en .env. Edítalo y pon tu clave primero."
    exit 1
  fi
}

activate_venv() {
  if [[ ! -d "venv" ]]; then
    error "No existe venv. Ejecuta primero ./setup_local.sh"
    exit 1
  fi
  # shellcheck disable=SC1091
  source venv/bin/activate
}

# Lotea y llama al management command con títulos
seed_titles_batch() {
  python - "$BATCH_SIZE" <<'PY'
import sys, subprocess, shlex

BATCH=int(sys.argv[1])

# Lista de títulos por defecto si no se da archivo:
titles = [
 "Dunkirk","Coco","Interstellar","Inception","Gladiator",
 "The Dark Knight","Titanic","Her","Joker","Toy Story",
 "Pulp Fiction","Forrest Gump","The Matrix","The Social Network",
 "La La Land","Arrival","Whiplash","Parasite","Spirited Away","Up",
 "Goodfellas","The Godfather","The Godfather Part II","Braveheart",
 "WALL·E","Inside Out","The Prestige","Blade Runner 2049","Mad Max: Fury Road","The Grand Budapest Hotel"
]

# Si existe un archivo "seed_titles.txt" u otro pasado por flag, lo usamos:
# Nota: el nombre se pasa por variable de entorno SEED_TITLES_FILE
import os
tf = os.environ.get("SEED_TITLES_FILE")
if tf and os.path.isfile(tf):
    with open(tf, "r", encoding="utf-8") as fh:
        titles = [line.strip() for line in fh if line.strip()]

for i in range(0, len(titles), BATCH):
    chunk = titles[i:i+BATCH]
    cmd = ["python","manage.py","movies_llm_descriptions","--titles", *chunk]
    print(f"[INFO] Enviando batch {i}-{i+len(chunk)}: {chunk}")
    subprocess.run(cmd, check=False)
PY
}

build_embeddings() {
  info "Construyendo embeddings…"
  python manage.py build_embeddings || true
}

# --- flujo principal ---
require_cmd python3
require_cmd pip

if [[ ! -f "manage.py" ]]; then
  error "No se encontró manage.py en el directorio actual."
  exit 1
fi

need_openai_key
activate_venv

# Inyectar var de entorno para Python inline
export SEED_TITLES_FILE="${TITLES_FILE}"

info "Generando descripciones de películas con GPT…"
seed_titles_batch

build_embeddings

info "Listo. Abre http://127.0.0.1:8000/recs/ y prueba el recomendador."
