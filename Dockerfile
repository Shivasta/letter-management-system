# ─────────────────────────────────────────────
#  MEF Portal – Production Docker Image
#  Multi-stage build for minimal final image
# ─────────────────────────────────────────────

# ── Stage 1: Build / dependency install ──────
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build tools required by some Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc \
        default-libmysqlclient-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install --prefix=/install --no-cache-dir -r requirements.txt

# ── Stage 2: Runtime image ────────────────────
FROM python:3.11-slim AS runtime

WORKDIR /app

# Bring in only the installed packages from the builder
COPY --from=builder /install /usr/local

# Copy application source
COPY . .

# Non-root user for security
RUN useradd -m mefuser && chown -R mefuser:mefuser /app
USER mefuser

# Expose the application port
EXPOSE 5000

# Environment defaults (override via docker-compose / -e flags)
ENV FLASK_ENV=production \
    FLASK_HOST=0.0.0.0 \
    FLASK_PORT=5000 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/healthz')" || exit 1

CMD ["python", "run.py"]
