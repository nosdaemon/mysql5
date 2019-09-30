include env_make

VERSION ?= latest
RELEASE = `date +%s`
RMI ?= `docker images | grep "^$(NS)/$(REPO)" | awk "{print \\$$3}"|uniq`
RMITEST ?= `docker images | grep "^$(NS)/$(REPO)" | awk "{print \\$$3}"|wc -l |awk "{print $$1}"`
RUN ?= `docker ps |grep "$(NS)/$(REPO):$(VERSION)" |wc -l |awk "{print $$1}"`
NORUN ?= `docker ps --all |grep "$(NS)/$(REPO):$(VERSION)" |wc -l |awk '{print $$1}'`
BUILDID=$(shell date +%Y%m%d-%H:%M:%S)
MAKEFLAGS += --silent

#INSTANCE = default

test: clean build run

login:
	docker login $(SRV):$(SRVPORT)

build:
	docker build --no-cache -t $(NS)/$(REPO):$(VERSION) .
	docker build -t $(NS)/$(REPO):$(RELEASE) .

tag:
	echo "Tag:" $(NS)/$(REPO)
	docker tag $(NS)/$(REPO) $(SRV):$(SRVPORT)/$(NS)/$(REPO):$(VERSION)
	docker tag $(NS)/$(REPO) $(SRV):$(SRVPORT)/$(NS)/$(REPO):$(RELEASE)

push: tag
	docker push $(SRV):$(SRVPORT)/$(NS)/$(REPO):$(RELEASE)

release: tag
	docker push $(SRV):$(SRVPORT)/$(NS)/$(REPO):$(VERSION)
	#docker push $(SRV):$(SRVPORT)/$(NS)/$(REPO):$(RELEASE)

run:
	docker run -d --restart=always -e MYSQL_ROOT_PASSWORD="FMS4Ever!" -e MYSQL_ROOT_HOST="%" -h $(NAME) --name $(NAME) $(NS)/$(REPO):$(VERSION)

rmi:
	test $(RMITEST) = 0 && echo "No Images" || docker rmi -f $(RMI)

pushall: build push

releaseall: build release

clean:
	test $(RUN) = 0 && echo "No Docker Running" || docker stop $(NAME)
	test $(NORUN) = 0 && echo "No Runing to remove" || docker rm $(NAME)
	test $(RMITEST) = 0 && echo "No Inmages" || docker rmi -f $(RMI)

default: login
