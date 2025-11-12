<!--
  Movie Reviews — README
  If this renders on GitHub, HTML blocks and badges will look nice. Enjoy!
-->

<h1 align="center">🎬 Movie Reviews — Django App</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Django-5.x-092E20?style=for-the-badge&logo=django&logoColor=white" />
  <img src="https://img.shields.io/badge/Python-3.12-3776AB?style=for-the-badge&logo=python&logoColor=white" />
  <img src="https://img.shields.io/badge/OpenAI-Embeddings-412991?style=for-the-badge&logo=openai&logoColor=white" />
  <img src="https://img.shields.io/badge/License-Choose%20one-blue?style=for-the-badge" />
</p>

<p align="center">
  <strong>Busca películas, publica reseñas, lee noticias y disfruta un recomendador basado en <i>embeddings</i>.</strong><br/>
  <em>Incluye scripts de instalación y seed IA para correr local en minutos.</em>
</p>

<br/>

## 🎨 Paleta de colores (UI)
<div align="center">
  <table>
    <tr>
      <td align="center"><code>#fcecc9</code><br/><div style="width:140px;height:26px;background:#fcecc9;border-radius:6px;"></div><br/>dutch-white</td>
      <td align="center"><code>#fcb0b3</code><br/><div style="width:140px;height:26px;background:#fcb0b3;border-radius:6px;"></div><br/>cherry-blossom-pink</td>
      <td align="center"><code>#f93943</code><br/><div style="width:140px;height:26px;background:#f93943;border-radius:6px;"></div><br/>imperial-red</td>
      <td align="center"><code>#7eb2dd</code><br/><div style="width:140px;height:26px;background:#7eb2dd;border-radius:6px;"></div><br/>carolina-blue</td>
      <td align="center"><code>#445e93</code><br/><div style="width:140px;height:26px;background:#445e93;border-radius:6px;"></div><br/>yinmn-blue</td>
    </tr>
  </table>
</div>

> La app ya trae estilos modernos y responsivos usando esta paleta (ver `static/css/theme.css`).

---

## ✨ Características
- 🔎 **Búsqueda de películas** por nombre (con imagen, url y descripción).
- 📝 **Reseñas** con fecha, contenido, autor y botón “ver otra vez”.
- 🔐 **Autenticación** (login/logout), permisos para editar/borrar solo tus reseñas.
- 📰 **News** con titulares, historias y fechas (ordenado por lo más reciente).
- 🤖 **Recomendador** por similitud semántica usando **embeddings** de OpenAI.
- 🧰 **Scripts** `setup_local.sh` y `seed_ai.sh` para instalar y sembrar datos IA.
- 🧪 **Comandos Django** para generar descripciones y embeddings.

---

## 🧱 Requisitos
- Python **3.12+**
- Git y Bash (Linux/macOS o WSL)
- (Opcional) **OpenAI API Key** para IA

---

## ⚡ Instalación Rápida

```bash
# 1) Clonar
git clone git@github.com:AdyuerHack/movie-reviews.git
cd movie-reviews

# 2) Dar permisos y ejecutar setup (crea venv, instala deps, migra DB, prepara .env)
chmod +x setup_local.sh seed_ai.sh
./setup_local.sh --no-runserver

# 3) Configurar OpenAI (opcional, para el recomendador y descripciones)
cp .env.example .env
nano .env
# -> Pega tu OPENAI_API_KEY="sk-..."

# 4) Sembrar IA (descripciones + embeddings)
./seed_ai.sh

# 5) Ejecutar
python manage.py runserver
# http://127.0.0.1:8000
```

**Rutas útiles:**

- Movies: `http://127.0.0.1:8000/movies/`
- Recs (recomendador): `http://127.0.0.1:8000/recs/`
- News: `http://127.0.0.1:8000/news/`
- Login: `http://127.0.0.1:8000/login/`

---

## ⚙️ Variables de entorno

Crea tu `.env` desde `/.env.example`:

```bash
cp .env.example .env
nano .env
```

Campos principales:

```env
# Django
DJANGO_DEBUG=1
ALLOWED_HOSTS=127.0.0.1,localhost
SECRET_KEY="se genera automáticamente si está vacío"

# OpenAI (opcional, solo para IA)
OPENAI_API_KEY="sk-..."                 # Requerido para seed IA y recomendador
OPENAI_TEXT_MODEL="gpt-4o-mini"
OPENAI_EMB_MODEL="text-embedding-3-small"
OPENAI_IMAGE_MODEL=""                   # Dejar vacío si no tienes acceso a gpt-image-1
```

> El script `setup_local.sh` creará `.env` si no existe y generará `SECRET_KEY` automáticamente.

---

## 🧪 Comandos Django (IA y más)

```bash
# Migraciones
python manage.py makemigrations
python manage.py migrate

# Crear superusuario (dev)
python manage.py createsuperuser

# Regenerar embeddings desde descripciones existentes
python manage.py build_embeddings

# Generar descripciones con LLM para títulos puntuales
python manage.py movies_llm_descriptions --titles "Dunkirk" "Coco" "Interstellar"
```

> También puedes pasar archivos de títulos al script `seed_ai.sh` con `--titles-file`.

---

## 🧰 Scripts incluidos

### `setup_local.sh`
- Crea y activa `venv/`
- Instala `requirements.txt`
- Crea `.env` si falta y genera `SECRET_KEY` si está vacío
- Aplica migraciones
- Crea usuario admin demo (`admin/admin`) si pasas `--create-superuser`
- Opcionalmente arranca el server (`--host` y `--port`)

**Ejemplos:**
```bash
./setup_local.sh --no-runserver
./setup_local.sh --create-superuser
./setup_local.sh --host 0.0.0.0 --port 8000
```

### `seed_ai.sh`
- Verifica `OPENAI_API_KEY`
- Genera/actualiza **descripciones** con LLM
- Construye **embeddings** y los guarda en DB

**Ejemplos:**
```bash
./seed_ai.sh                       # usa el set por defecto
./seed_ai.sh --batch 20            # define tamaño de lotes
./seed_ai.sh --titles-file seed_titles.txt
```

---

## 🩺 Solución de Problemas

**1) `TemplateDoesNotExist`**
- Asegúrate que los templates existan y que `settings.py` incluya `APP_DIRS=True` y `DIRS=[BASE_DIR / "templates"]`.

**2) `TemplateSyntaxError: now|"date:'Y'"`**
- Usa `{% now "Y" %}` en plantillas (ya está corregido en `base.html`).

**3) Error OpenAI 403 (imágenes)**
- Si ves: “organization must be verified to use `gpt-image-1`”, deja `OPENAI_IMAGE_MODEL=""` para usar solo texto+embeddings.

**4) `SyntaxError: source code string cannot contain null bytes`**
- Reemplaza el archivo dañado volviendo a pegar el contenido en UTF-8 (sin BOM).

---

## 🧭 Flujo del Recomendador (resumen)

1. **Descripciones** de películas en DB (manuales o generadas por LLM).
2. **Embeddings** calculados desde descripciones (OpenAI) → guardados en DB.
3. En `/recs/`: el usuario escribe un **prompt** → se calcula embedding →
4. Se mide **similaridad** coseno con todas las películas →
5. Se retorna una **lista ordenada** (más similares primero).

---

## 🤝 Contribuir

```bash
git checkout -b feature/tu-feature
git commit -m "feat: agrega X"
git push origin feature/tu-feature
# Abre un Pull Request
```

---

## 📄 Licencia
Proyecto educativo. Elige una licencia (MIT/Apache-2.0) y agrégala al repositorio.

---

<p align="center">
  Hecho con ❤️ usando Django · UI inspirada en la paleta del proyecto
</p>
