# Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copie du code source, qui a été préparé par GoReleaser
COPY . /app

RUN pip install uv
# Installation des dépendances (optionnel, si vous utilisez les 'extra_files')
# L'idée est de garder cette étape légère, car GoReleaser a déjà fait le gros du travail.
#pip install --no-cache-dir -r requirements.txt
RUN uv sync

# Exposition du port Flask
EXPOSE 5000

# Variables d'environnement
ENV FLASK_APP=main.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV PATH="/app/.venv/bin:$PATH"

# Commande de démarrage
CMD ["python", "main.py"]