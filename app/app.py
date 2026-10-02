import os

from flask import Flask, jsonify

app = Flask(__name__)

# Set per environment by Terraform (app_settings.APP_ENV).
APP_ENV = os.environ.get("APP_ENV", "local")


@app.get("/")
def hello():
    return f"Hello world from shams {APP_ENV.upper()}!"


@app.get("/health")
def health():
    # App Service health check probes this path (site_config.health_check_path).
    return jsonify(status="ok", env=APP_ENV)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", "8000")))
