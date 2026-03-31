module hello

go 1.13

require (
	github.com/golang/protobuf v1.5.2
	golang.org/x/net v0.7.0
	google.golang.org/grpc v1.53.0
)

replace hello/hello => ./hello
