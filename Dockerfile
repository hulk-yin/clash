FROM golang:1.18-alpine as builder

RUN apk add --no-cache make git 
RUN wget -O /Country.mmdb https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb


WORKDIR /clash-src
COPY --from=tonistiigi/xx:golang / /
COPY . /clash-src

ENV GO111MODULE=on GOPROXY=https://proxy.golang.com.cn,direct

RUN go version && go mod download 

 
RUN make linux-386 && \
    mv ./bin/clash-docker /clash

FROM alpine:latest
LABEL org.opencontainers.image.source="https://github.com/Dreamacro/clash"

RUN apk add --no-cache ca-certificates tzdata
COPY --from=builder /Country.mmdb /root/.config/clash/
COPY --from=builder /clash /


RUN mkdir -p ~/.config/clash

RUN wget  -O ~/.config/clash/config.yaml "https://getconf.net/clash/114917/999632d9"

ENTRYPOINT ["/clash"]
