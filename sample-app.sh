#!/bin/bash

# --- Bersihkan container & image lama ---
docker stop samplerunning 2>/dev/null
docker rm samplerunning 2>/dev/null
docker rmi sampleapp 2>/dev/null
rm -rf tempdir

# --- Siapkan folder build ---
mkdir -p tempdir/templates
mkdir -p tempdir/static

cp sample_app.py tempdir/.
cp -r templates/* tempdir/templates/.
cp -r static/* tempdir/static/.
cp requirements.txt tempdir/.

# --- Buat Dockerfile ---
cat <<EOF > tempdir/Dockerfile
FROM python:3.11-slim

ENV PIP_NO_PROGRESS_BAR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

COPY requirements.txt /tmp/
RUN python -m pip install --no-cache-dir --progress-bar off -r /tmp/requirements.txt

COPY ./static /home/myapp/static/
COPY ./templates /home/myapp/templates/
COPY sample_app.py /home/myapp/

WORKDIR /home/myapp
EXPOSE 5050

# Default: Gunicorn WSGI server
# Fallback: Flask dev server jika Gunicorn gagal
CMD gunicorn -b 0.0.0.0:5050 sample_app:sample || python sample_app.py --no-debugger
EOF

# --- Build & Run ---
cd tempdir
docker build -t sampleapp .
docker run -t -d -p 5050:5050 --name samplerunning sampleapp

# --- Tampilkan status & log ---
echo "=== Daftar container aktif ==="
docker ps
echo ""
echo "=== Log Aplikasi (Gunicorn/Flask) ==="
docker logs -f samplerunning