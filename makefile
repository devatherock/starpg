.PHONY : editor-install-deps editor-build install-deps start
GOPACKAGES = go.starlark.net/starlark github.com/sirupsen/logrus github.com/qri-io/starlib
docker_tag = latest
skip_pull = false
all = false

default: editor-install-deps editor-build install-deps run


editor-install-deps: 
	@echo "\ninstalling editor deps\n"
	( cd editor; yarn install )

editor-build:
	@echo "\nbuild editor\n"
	( cd editor; yarn webpack --config=webpack.config.js )

install-deps:
	@echo "\ninstalling go deps\n"
	go get -v -u $(GOPACKAGES)

start:
	@echo "\nstart service\n"
	go install && starpg

update-changelog:
	conventional-changelog -p angular -i CHANGELOG.md -s

check:
ifeq ($(all), true)
	yamllint -d relaxed .circleci render.yaml --no-warnings
endif
	gofmt -l -w -s .
	go vet
	
build-all:
	CGO_ENABLED=0 GOOS=linux go build -o release/starpg
	
run:
	@echo "\nbuild and run\n"
	go build -o release/starpg
	./release/starpg
	
clean:
	go clean -testcache
	rm -rf release

docker-build:
	docker build -t devatherock/starpg:$(docker_tag) \
	    -f build/Dockerfile .
	
integration-test:
ifneq ($(skip_pull), true)
	docker pull devatherock/starpg:$(docker_tag)
endif
	DOCKER_TAG=$(docker_tag) docker-compose -f build/docker-compose.yml up -d
	sleep 1
	go test -v ./...
	docker-compose -f build/docker-compose.yml down		