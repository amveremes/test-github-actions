# Dockerfile - Version finale avec venv
FROM debian:trixie-slim

RUN apt update && \
    apt install -y --no-install-recommends ca-certificates curl && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv && \
    mv /root/.local/bin/uvx /usr/local/bin/uvx && \
    apt purge -y curl && \
    apt autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN uv python install 3.11 && \
    uv python pin 3.11

WORKDIR /app

COPY main.py pyproject.toml uv.lock ./

# Création du venv et synchronisation
RUN uv venv && \
    . .venv/bin/activate && \
    uv sync

# Activation du venv pour le runtime
ENV PATH="/app/.venv/bin:$PATH"
ENV FLASK_APP=main.py
ENV FLASK_RUN_HOST=0.0.0.0

EXPOSE 5000

CMD ["python", "main.py"]