# Dockerfile - Version finale avec venv
ARG PYTHON_VERSION=3.12

FROM python:${PYTHON_VERSION}-slim

# Éviter les invites interactives
ENV DEBIAN_FRONTEND=noninteractive

# (Optionnel mais recommandé) Améliore les performances d'installation
ENV UV_COMPILE_BYTECODE=1

# 3. On définit le répertoire de travail
WORKDIR /app

# Configure environment
# superset/gunicorn recommended defaults:
# - https://superset.apache.org/docs/installation/configuring-superset#running-on-a-wsgi-http-server
# - https://docs.gunicorn.org/en/latest/configure.html
ENV FLASK_APP=superset
ENV GUNICORN_BIND=0.0.0.0:8088
ENV GUNICORN_LIMIT_REQUEST_FIELD_SIZE=8190
ENV GUNICORN_LIMIT_REQUEST_LINE=4094
ENV GUNICORN_THREADS=4
ENV GUNICORN_TIMEOUT=120
ENV GUNICORN_WORKERS=10
ENV GUNICORN_WORKER_CLASS=gevent
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONPATH=/etc/superset:/home/superset
ENV SUPERSET_HOME=/var/lib/superset
ENV GUNICORN_CMD_ARGS="--bind $GUNICORN_BIND --limit-request-field_size $GUNICORN_LIMIT_REQUEST_FIELD_SIZE --limit-request-line $GUNICORN_LIMIT_REQUEST_LINE --threads $GUNICORN_THREADS --timeout $GUNICORN_TIMEOUT --workers $GUNICORN_WORKERS --worker-class $GUNICORN_WORKER_CLASS"
ENV UV_PYTHON_INSTALL_DIR=/usr/local

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Définir le répertoire de travail
WORKDIR /app

COPY main.py pyproject.toml uv.lock ./

# Création du venv et synchronisation
RUN uv venv

EXPOSE 8088

CMD ["python", "main.py"]

# Configure filesystem
#COPY bin /usr/local/bin
VOLUME /etc/superset
VOLUME /home/superset
VOLUME /var/lib/superset

# Create superset user & install dependencies
WORKDIR /home/superset

# Créer l'utilisateur superset avec UID/GID 1000
RUN groupadd -r superset -g 1000 && \
    useradd -r -g superset -u 1000 -m -s /bin/bash superset && \
    mkdir -p $SUPERSET_HOME && \
    chown -R superset:superset $SUPERSET_HOME && \
    chown -R superset:superset /home/superset && \
    chown -R superset:superset /etc/superset && \
    apt update && \
    apt install -y \
    build-essential \
    curl \
    default-libmysqlclient-dev \
    freetds-bin \
    freetds-dev \
    libecpg-dev \
    libffi-dev \
    libldap2-dev \
    libpq-dev \
    libsasl2-2 \
    libsasl2-dev \
    libsasl2-modules-gssapi-mit \
    libssl-dev && \
    apt-get clean

# Passer à l'utilisateur superset
USER superset

# Configure application
EXPOSE 8088
USER superset
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
CMD ["gunicorn", "superset.app:create_app()"]