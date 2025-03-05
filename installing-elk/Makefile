install_elk:
	curl -fsSL https://elastic.co/start-local | sh
install_linux:
	docker image build -t elastic-alpine .
	docker run --name elastic-alpine-img --rm -it -p 9200:9200 -p 9300:9300 elastic-alpine