ARG GO_VERSION=1.17
FROM golang:${GO_VERSION}-alpine3.16 AS build

COPY . /home/workspace
WORKDIR /home/workspace

RUN go build -o release/starpg


FROM alpine:3.16.6

LABEL maintainer="devatherock@gmail.com"

COPY --from=build /home/workspace/release/starpg /bin/starpg

COPY --from=build /home/workspace/editor/ /editor/

CMD ["/bin/starpg"]