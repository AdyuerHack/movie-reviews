from pathlib import Path
from dotenv import load_dotenv
import os

# --- Paths base ---
BASE_DIR = Path(__file__).resolve().parent.parent  # carpeta donde está manage.py

# --- Cargar variables de entorno desde .env (unificado) ---
# Coloca tu .env junto a manage.py
# Ejemplo .env:
# SECRET_KEY="tu_clave_segura"
# DJANGO_DEBUG=1
# ALLOWED_HOSTS=127.0.0.1,localhost
# OPENAI_API_KEY="sk-xxxx"
# OPENAI_TEXT_MODEL="gpt-4o-mini"
# OPENAI_EMB_MODEL="text-embedding-3-small"
# OPENAI_IMAGE_MODEL=""
load_dotenv(BASE_DIR / ".env")

# --- Seguridad y modo ---
SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret-key-change-me")
DEBUG = bool(int(os.getenv("DJANGO_DEBUG", "1")))
ALLOWED_HOSTS = [h for h in os.getenv("ALLOWED_HOSTS", "").split(",") if h]  # p.ej. "127.0.0.1,localhost"

# --- Apps instaladas ---
INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "movies",
    "recs",  # app de recomendación
]

# --- Middleware ---
MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

# --- URLs / WSGI ---
ROOT_URLCONF = "moviereviews.urls"
WSGI_APPLICATION = "moviereviews.wsgi.application"

# --- Templates ---
TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "templates"],  # templates/ en la raíz del proyecto
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

# --- Base de datos ---
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": BASE_DIR / "db.sqlite3",
    }
}

# Validadores de password (vacío para desarrollo; ajusta si usas producción)
AUTH_PASSWORD_VALIDATORS = []

# --- I18N / TZ ---
LANGUAGE_CODE = "es"
TIME_ZONE = "America/Bogota"
USE_I18N = True
USE_TZ = True

# --- Static ---
STATIC_URL = "static/"
STATICFILES_DIRS = [BASE_DIR / "static"]  # carpeta static/ en la raíz
# Si algún día despliegas en producción:
# STATIC_ROOT = BASE_DIR / "staticfiles"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# --- Auth redirects ---
LOGIN_URL = "login"
LOGIN_REDIRECT_URL = "home"
LOGOUT_REDIRECT_URL = "home"

# --- OpenAI: se leen del .env unificado ---
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
OPENAI_TEXT_MODEL = os.getenv("OPENAI_TEXT_MODEL", "gpt-4o-mini")
OPENAI_EMB_MODEL = os.getenv("OPENAI_EMB_MODEL", "text-embedding-3-small")
OPENAI_IMAGE_MODEL = os.getenv("OPENAI_IMAGE_MODEL", "")
