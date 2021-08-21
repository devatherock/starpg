.PHONY : editor-install-deps editor-build install-deps start
GOPACKAGES = go.starlark.net/starlark github.com/sirupsen/logrus github.com/qri-io/starlib

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
	gofmt -l -w -s .
	go vet
	
build:
	go build -o release/starpg
	
run:
	@echo "\nbuild and run\n"
	go build -o release/starpg
	./release/starpg	