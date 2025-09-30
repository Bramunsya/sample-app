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
