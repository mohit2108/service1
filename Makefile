DOCKER_REGISTRY=docker.repo1.uhc.com/hcc-k8s/test1
DOCKER_IMAGE=service1:latest


docker-build:
	docker build . -t "${DOCKER_REGISTRY}/${DOCKER_IMAGE}"

docker-push: docker-build
	docker push "${DOCKER_REGISTRY}/${DOCKER_IMAGE}"

deploy:
	kubectl -k ./deployment
