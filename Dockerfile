FROM golang:1.22-alpine as go-build

WORKDIR /app

# Copy go mod files first for better caching
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . ./

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o qmsk-dmx ./cmd/qmsk-dmx




FROM node:20-alpine as web-build

WORKDIR /app/web

COPY web/package.json ./
RUN npm install

COPY web ./
RUN ./node_modules/typescript/bin/tsc


# Final stage with minimal Alpine Linux
FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata
RUN mkdir -p /opt/qmsk-dmx /opt/qmsk-dmx/bin

COPY --from=go-build /app/qmsk-dmx /opt/qmsk-dmx/bin/
COPY --from=web-build /app/web/ /opt/qmsk-dmx/web
COPY library/ /opt/qmsk-dmx/library

WORKDIR /opt/qmsk-dmx
VOLUME /etc/qmsk-dmx
ENV ARTNET_DISCOVERY=2.255.255.255
CMD ["/opt/qmsk-dmx/bin/qmsk-dmx", \
  "--log=info", \
  "--http-listen=:8000", \
  "--http-static=/opt/qmsk-dmx/web/", \
  "--heads-library=/opt/qmsk-dmx/library/", \
  "/etc/qmsk-dmx" \
]

EXPOSE 8000
