setup:
	chmod +x scripts/pipeline.sh scripts/artifacts.sh

up:
	docker compose up -d

down:
	docker compose down

clean:
	docker compose down -v

pipeline:
	./scripts/pipeline.sh

artifacts:
	./scripts/artifacts.sh