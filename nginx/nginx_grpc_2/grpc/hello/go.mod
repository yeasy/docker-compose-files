module hello

go 1.13

require (
	github.com/golang/protobuf v1.3.2
	golang.org/x/net v0.0.0-20190311183353-d8887717615a
	google.golang.org/grpc v1.24.0
)

replace hello/hello => ./hello
