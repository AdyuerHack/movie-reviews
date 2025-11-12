#!/usr/bin/env bash
# setup_local.sh — Prepara el entorno local sin IA (venv, deps, .env, SECRET_KEY, migraciones) y (opcional) arranca el server.
# Uso:
#   chmod +x setup_local.sh
#   ./setup_local.sh                 # prepara y arranca en 127.0.0.1:8000
#   ./setup_local.sh --no-runserver  # prepara todo, pero no arranca el server
#   ./setup_local.sh --create-superuser   # crea admin:admin (solo dev)
#   ./setup_local.sh --host 0.0.0.0 --port 8000

set -euo pipefail

HOST="127.0.0.1"
PORT="8000"
RUNSERVER="1"
CREATE_SUPER="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-runserver) RUNSERVER="0"; shift ;;
    --create-superuser) CREATE_SUPER="1"; shift ;;
    --host) HOST="${2:-127.0.0.1}"; shift 2 ;;
    --port) PORT="${2:-8000}"; shift 2 ;;
    *) echo "Flag no reconocido: $1"; exit 1 ;;
  esac
done

info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { error "No se encontró '$1'. Instálalo y reintenta."; exit 1; }
}

generate_secret_key() {
  python3 - <<'PY'
from django.core.management.utils import get_random_secret_key
print(get_random_secret_key())
PY
}

ensure_env_file() {
  if [[ ! -f ".env" ]]; then
    if [[ -f ".env.example" ]]; then
      info "Creando .env desde .env.example…"
      cp .env.example .env
    else
      warn "No existe .env ni .env.example; creando .env mínimo…"
      cat > .env <<EOF
SECRET_KEY=""
DJANGO_DEBUG=1
ALLOWED_HOSTS=127.0.0.1,localhost

# OpenAI (puedes dejarlos vacíos si no usarás IA todavía)
OPENAI_API_KEY=""
OPENAI_TEXT_MODEL="gpt-4o-mini"
OPENAI_EMB_MODEL="text-embedding-3-small"
OPENAI_IMAGE_MODEL=""
EOF
    fi
  fi

  # Completar SECRET_KEY si falta
  if ! grep -qE '^SECRET_KEY=' .env || [[ -z "$(grep -E '^SECRET_KEY=' .env | cut -d'=' -f2-)" ]]; then
    info "Generando SECRET_KEY para .env…"
    SK=$(generate_secret_key)
    SK_ESC="${SK//\"/\\\"}"
    if grep -qE '^SECRET_KEY=' .env; then
      sed -i 's/^SECRET_KEY=.*/SECRET_KEY="'"$SK_ESC"'"/' .env
    else
      printf '\nSECRET_KEY="%s"\n' "$SK_ESC" >> .env
    fi
  fi

  # Asegura comillas en SECRET_KEY
  if grep -qE '^SECRET_KEY=' .env && ! grep -qE '^SECRET_KEY=".*"$' .env; then
    val=$(grep -E '^SECRET_KEY=' .env | cut -d'=' -f2-)
    sed -i 's/^SECRET_KEY=.*/SECRET_KEY="'"$val"'"/' .env
  fi
}

activate_venv() {
  if [[ ! -d "venv" ]]; then
    info "Creando entorno virtual (venv)…"
    python3 -m venv venv
  fi
  # shellcheck disable=SC1091
  source venv/bin/activate
}

install_requirements() {
  info "Actualizando pip y wheel…"
  python -m pip install --upgrade pip wheel
  if [[ -f "requirements.txt" ]]; then
    info "Instalando dependencias de requirements.txt…"
    pip install -r requirements.txt
  else
    warn "No hay requirements.txt; instalando mínimos…"
    pip install "django==5.*" python-dotenv openai httpx
  fi
}

run_migrations() {
  info "Aplicando migraciones…"
  python manage.py makemigrations
  python manage.py migrate
}

create_superuser_if_requested() {
  if [[ "$CREATE_SUPER" == "1" ]]; then
    info "Creando superusuario admin:admin (solo desarrollo)…"
    export DJANGO_SUPERUSER_USERNAME=admin
    export DJANGO_SUPERUSER_EMAIL=admin@example.com
    export DJANGO_SUPERUSER_PASSWORD=admin
    python manage.py createsuperuser --noinput || true
  fi
}

start_server() {
  if [[ "$RUNSERVER" == "0" ]]; then
    info "Preparación lista. No se arrancará runserver (--no-runserver)."
    return 0
  fi
  info "Iniciando servidor: http://${HOST}:${PORT}"
  python manage.py runserver "${HOST}:${PORT}"
}

# --- flujo principal ---
require_cmd python3
require_cmd pip

if [[ ! -f "manage.py" ]]; then
  error "No se encontró manage.py en el directorio actual."
  exit 1
fi

ensure_env_file
activate_venv
install_requirements
run_migrations
create_superuser_if_requested
start_server
