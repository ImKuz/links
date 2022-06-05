#!/usr/bin/env bash

protoc \
  --swift_opt=Visibility=Public \
  --grpc-swift_opt=Client=true,Server=true,Visibility=Public \
  --swift_out=../App/Modules/Modules/Contracts/Sources/ \
  --grpc-swift_out=../App/Modules/Modules/Contracts/Sources/ \
  -I../protocols ../protocols/*.proto