# Dockerfile
FROM python:3.11-slim

ARG TARGETPLATFORM
WORKDIR /app

# Copie des fichiers
COPY main.py pyproject.toml uv.lock ./

RUN pip install uv
RUN uv venv
ENV PATH="/app/.venv/bin:$PATH"
RUN uv sync

EXPOSE 5000
ENV FLASK_APP=main.py
ENV FLASK_RUN_HOST=0.0.0.0

CMD ["python", "main.py"]