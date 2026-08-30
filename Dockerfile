FROM python:3.12-slim
WORKDIR /app
COPY apps/requirements.txt .
RUN pip install  --no-cache-dir -r requirements.txt
COPY apps/ .
RUN useradd --create-home appuser
USER appuser
EXPOSE 5000
CMD ["python", "app.py"]
#CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--access-logfile", "-", "--error-logfile", "-", "app:app"]