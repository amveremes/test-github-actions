# Dockerfile
# Ce fichier doit être à la racine de votre projet
FROM python:3.11-slim

WORKDIR /app

# Copie du code source, qui a été préparé par GoReleaser
COPY . /app

RUN pip install uv
# Installation des dépendances (optionnel, si vous utilisez les 'extra_files')
# L'idée est de garder cette étape légère, car GoReleaser a déjà fait le gros du travail.
#pip install --no-cache-dir -r requirements.txt
RUN uv sync

# Exécution de votre application
CMD ["python", "main.py"]
