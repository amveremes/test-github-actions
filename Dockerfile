# Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copie des fichiers nécessaires
COPY requirements.txt .
COPY main.py .

# Installation des dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Exposition du port Flask par défaut
EXPOSE 5000

# Variable d'environnement pour Flask
ENV FLASK_APP=main.py
ENV FLASK_RUN_HOST=0.0.0.0

# Commande de démarrage
CMD ["python", "main.py"]