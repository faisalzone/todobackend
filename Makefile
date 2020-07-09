.PHONY: test release clean version login logout publish

export APP_VERSION ?= $(shell git rev-parse --short HEAD)

version:
	@ echo '{"Version": "$(APP_VERSION)"}'

login:
	aws ecr get-login-password | docker login --username AWS --password-stdin 600163339681.dkr.ecr.ap-southeast-2.amazonaws.com

logout:
	docker logout https://600163339681.dkr.ecr.ap-southeast-2.amazonaws.com

test:
	docker-compose build --pull release
	docker-compose build
	docker-compose run test

release:
	docker-compose up --abort-on-container-exit migrate
	docker-compose run app python3 manage.py collectstatic --no-input
	docker-compose up --abort-on-container-exit acceptance
	@ echo App running at http://$$(docker-compose port app 8000 | sed s/0.0.0.0/localhost/g)

publish:
	docker-compose push release app

clean:
	docker-compose down -v
	docker images -q -f dangling=true -f label=application=todobackend | xargs -I ARGS docker rmi -f --no-prune ARGS