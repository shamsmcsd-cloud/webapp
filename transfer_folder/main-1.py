"""
Project 2 - Flask Application
Simple Hello World Web Service
"""
from flask import Flask, jsonify
import os

app = Flask(__name__)


@app.route('/', methods=['GET'])
def hello_world():
    """Return hello world message"""
    return jsonify({
        'message': 'Hello World from Project 2',
        'project': 'project2',
        'environment': os.getenv('ENVIRONMENT', 'development'),
        'version': '1.0.0'
    })


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'project': 'project2'}), 200


@app.route('/project2/info', methods=['GET'])
def project_info():
    """Project information endpoint"""
    return jsonify({
        'project_name': 'Project 2',
        'description': 'AI Foundry Service - Project 2',
        'status': 'running'
    })


if __name__ == '__main__':
    port = int(os.getenv('PORT', 8000))
    app.run(host='0.0.0.0', port=port, debug=False)
