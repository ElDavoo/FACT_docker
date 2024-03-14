all: backend frontend scripts

common:
	docker build \
		-f Dockerfile-common \
		-t fact-core-common \
		.

backend: common
	docker build \
		-f Dockerfile-backend \
		-t fact-core-backend \
		.

frontend: common
	docker build \
		-f Dockerfile-frontend \
		-t fact-core-frontend \
		.

scripts:
	docker build \
		-f Dockerfile-scripts \
		-t fact-core-scripts \
		.
