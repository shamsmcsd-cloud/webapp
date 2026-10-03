"""
Project 3 - Flask Application
Simple Hello World Web Service
"""
from flask import Flask, jsonify
import os

app = Flask(__name__)


@app.route('/', methods=['GET'])
def hello_world():
    """Return hello world message"""
    return jsonify({
        'message': 'Hello World from Project 3',
        'project': 'project3',
        'environment': os.getenv('ENVIRONMENT', 'development'),
        'version': '1.0.0'
    })


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'project': 'project3'}), 200


@app.route('/project3/info', methods=['GET'])
def project_info():
    """Project information endpoint"""
    return jsonify({
        'project_name': 'Project 3',
        'description': 'AI Foundry Service - Project 3',
        'status': 'running'
    })


if __name__ == '__main__':
    port = int(os.getenv('PORT', 8000))
    app.run(host='0.0.0.0', port=port, debug=False)
