# yeasy/hyperledger-fabric-peer:dev
# Dockerfile for developing Hyperledger peer image. This actually follow
# yeasy/hyperledger-fabric-peer image and add local source code to build the
# fabric binaries.
# Data is stored under /var/hyperledger/db and /var/hyperledger/production

FROM yeasy/hyperledger-fabric-base:latest
LABEL maintainer "Baohua Yang <yeasy.github.com>"

EXPOSE 7051

# ENV CORE_PEER_MSPCONFIGPATH $FABRIC_CFG_PATH/msp

COPY $GOPATH/src/github.com/hyperledger/fabric /go/src/github.com/hyperledger/

# install fabric peer and copy sampleconfigs
RUN cd $FABRIC_ROOT/peer \
    && CGO_CFLAGS=" " go install -ldflags "$LD_FLAGS -linkmode external -extldflags '-static -lpthread'" \
    && go clean

# This will start with joining the default chain "testchainid"
# Use `peer node start --peer-defaultchain=false` will join no channel by default. 
# Then need to manually create a chain with `peer channel create -c test_chain`, then join with `peer channel join -b test_chain.block`.
CMD ["peer","node","start"]
