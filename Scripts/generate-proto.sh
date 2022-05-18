#!/usr/bin/env bash

protoc \
  --swift_opt=Visibility=Public \
  --grpc-swift_opt=Client=true,Server=true \
  --swift_out=../submodules/Contracts/Sources/Contracts \
  --grpc-swift_out=../submodules/Contracts/Sources/Contracts \
  -I../protocols ../protocols/*.proto