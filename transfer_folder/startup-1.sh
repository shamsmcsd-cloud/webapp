#!/bin/bash
# Project 2 Startup Script for Azure Web App

cd /home/site/wwwroot/project2/app
pip install -r requirements.txt

# Start application with gunicorn
gunicorn \
  --bind=0.0.0.0 \
  --timeout 600 \
  --workers 4 \
  --worker-class sync \
  main:app
