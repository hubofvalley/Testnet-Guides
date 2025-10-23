# KiteAI — Overview

KiteAI is a lightweight model-serving and dataset management scaffold intended for development, testing, and demonstration purposes. This docs folder contains high-level guides and operational notes for running KiteAI locally or in CI.

## Architecture

KiteAI consists of:

- **api/**: Python Flask API for inference and health checks.
- **dashboard/**: Minimal static frontend for demos.
- **data/**: Example datasets and ingestion scripts.
- **resources/**: Deployment and helper scripts.
- **docs/**: This documentation and walkthroughs.

## Quickstart

1. Copy [`../.env.example`](../.env.example:1) to `.env` and fill required values.
2. Build and run with Docker Compose:

   docker compose up --build

3. API endpoints:
   - Health: `GET /health`
   - Ready: `GET /ready`
   - Predict: `POST /predict` (JSON body: `{ "text": "..." }`)

## Development

- Install dependencies:

  pip install -r requirements.txt

- Run API locally:

  python -m api.app

- Run tests:

  pytest

## Configuration

See [`../.env.example`](../.env.example:1) for available configuration variables and placeholders for secrets. Replace placeholders with real values before deploying to production.

## Contributing

Contributions are welcome. Please follow the guidelines in [`../CONTRIBUTING.md`](../CONTRIBUTING.md:1) and open pull requests for changes.

## License

This project is licensed under the MIT License. See [`../LICENSE`](../LICENSE:1) for details.