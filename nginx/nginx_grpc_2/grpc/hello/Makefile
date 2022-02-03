proto:
	protoc --go_out=plugins=grpc:. ./hello/*.proto
install:build
	cp grpc_server ${GOPATH}/bin
	cp grpc_client ${GOPATH}/bin
build:
	# GOPATH=/go
	go build -o grpc_server server/server.go
	go build -o grpc_client client/client.go
server:
	# GOPATH=$(PWD)/../../
	go run server/server.go
client:
	# GOPATH=$(PWD)/../../
	go run client/client.go

.PHONY: all proto server client test
