#!/bin/bash
# Project 1 Startup Script for Azure Web App

cd /home/site/wwwroot/project1/app
pip install -r requirements.txt

# Start application with gunicorn
gunicorn \
  --bind=0.0.0.0 \
  --timeout 600 \
  --workers 4 \
  --worker-class sync \
  main:app
