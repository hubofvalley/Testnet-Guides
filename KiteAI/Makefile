.PHONY: install run-api run-frontend lint test clean

install:
	pip install -r requirements.txt

run-api:
	python -m api.app

lint:
	flake8 api/ || true

test:
	pytest -q

clean:
	rm -rf __pycache__ .pytest_cache *.pyc *.pyo *.pyd