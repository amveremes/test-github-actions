# Dockerfile
FROM python:3.11-slim
WORKDIR /app

# Copie du code source, qui a été préparé par GoReleaser
COPY . /app

# Copie explicite des fichiers nécessaires
COPY pyproject.toml uv.lock ./
COPY main.py ./

RUN pip install uv

# Créer l'environnement virtuel et synchroniser
RUN uv venv

# Activer l'environnement virtuel
ENV PATH="/app/.venv/bin:$PATH"

RUN uv sync

# Exposition du port Flask
EXPOSE 5000

# Variables d'environnement
ENV FLASK_APP=main.py
ENV FLASK_RUN_HOST=0.0.0.0

# Commande de démarrage
CMD ["python", "main.py"]