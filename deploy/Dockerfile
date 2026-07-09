# xugu-exporter 多阶段构建。
# go-xugu-driver 为纯 Go 实现（无 cgo），可静态编译进最小镜像。
FROM golang:1.24-alpine AS builder
WORKDIR /src
ENV CGO_ENABLED=0 GOPROXY=https://goproxy.cn,direct
COPY go.mod go.sum ./
RUN go mod download
COPY . .
ARG VERSION=dev
RUN go build -trimpath -ldflags "-s -w -X main.version=${VERSION}" \
    -o /xugu-exporter ./cmd/xugu-exporter

FROM alpine:3.20
RUN adduser -D -u 65534 -g exporter exporter 2>/dev/null || true
COPY --from=builder /xugu-exporter /usr/local/bin/xugu-exporter
USER 65534
EXPOSE 9156
ENTRYPOINT ["/usr/local/bin/xugu-exporter"]
