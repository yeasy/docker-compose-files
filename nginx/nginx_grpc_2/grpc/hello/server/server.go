package main

import (
    "context"
    "fmt"
    "log"
    "net"

    "google.golang.org/grpc"
    pb "hello/hello"
    )

const (
	port = ":7050"
)

type server struct{ }

// implement server side interface methods
func (s *server) SayHello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloReply, error) {
	log.Printf("Received msg from: %s\n", in.GetName())
	return &pb.HelloReply{Message: "Hello " + in.GetName()}, nil
}

// start a gRPC server side: create socket, create, register and start the service
func main() {
	lis, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("failed to listen: %v\n", err)
	}
	s := grpc.NewServer()
	pb.RegisterGreeterServer(s, &server{})
	fmt.Printf("Starting listen on port: %s\n", port)
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
