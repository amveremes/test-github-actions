# =============================================================================
# Production Superset Dockerfile
#
# Basé sur la documentation officielle :
# https://superset.apache.org/admin-docs/installation/docker-builds
#
# Étend l'image lean officielle pour ajouter :
#   - Drivers de base de données (PostgreSQL metadata + vos DBs analytics)
#   - (Optionnel) Playwright pour Alerts & Reports
#   - Configuration custom (superset_config.py)
#
# Usage :
#   docker build -t mon-superset:prod .
#   docker build --build-arg TAG=5.0.0 -t mon-superset:5.0.0 .
# =============================================================================

ARG TAG=6.0.0
FROM apache/superset:${TAG} AS prod

USER root

# Variables d'environnement pour Playwright (si activé)
ENV PLAYWRIGHT_BROWSERS_PATH=/usr/local/share/playwright-browsers

# Installation des drivers Python via uv (package manager rapide de Superset)
# Activez le venv intégré et installez les packages requis
RUN apt-get update && \
    apt-get install -y \
    gcc \
    pkg-config \
    default-libmysqlclient-dev \
    && apt-get clean \
    &&  . /app/.venv/bin/activate && \
    uv pip install \
    # install python-dotenv:
    python-dotenv \
    # install psycopg2 PostgreSQL
    psycopg2-binary \
    # Redis (cache + Celery broker)
    redis \
    # Autres drivers selon vos besoins analytics :
    # Microsoft SQL Server
    pymssql \
    # MySQL
    mysqlclient \
    # ClickHouse
    # clickhouse-driver \
    # Trino
    # trino \
    \
    # Authentication SSO
    Authlib \
    \
    # Excel uploads
    openpyxl \
    # PDF generation pour Alerts & Reports
    Pillow \
    # install Playwright for taking screenshots for Alerts & Reports. This assumes the feature flag PLAYWRIGHT_REPORTS_AND_THUMBNAILS is enabled
    # That feature flag will default to True starting in 6.0.0
    # Playwright works only with Chrome.
    # If you are still using Selenium instead of Playwright, you would instead install here the selenium package and a headless browser & webdriver
    #playwright \
    #&& playwright install-deps \
    #&& PLAYWRIGHT_BROWSERS_PATH=/usr/local/share/playwright-browsers playwright install chromium \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

# Copier la configuration custom (sans secrets)
COPY --chown=superset:superset .env /app/config/.env
COPY --chown=superset:superset superset_config.py /app/config/superset_config.py

# Variables d'environnement
ENV PYTHONPATH="/app/config:$PYTHONPATH" \
    SUPERSET_CONFIG_PATH="/app/config/superset_config.py"

USER superset

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8088/health || exit 1

CMD ["/app/docker/entrypoints/run-server.sh"]
