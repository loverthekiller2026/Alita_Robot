# syntax=docker/dockerfile:1

# Build with the Go version required by go.mod.
FROM golang:1.27-alpine AS builder

RUN apk add --no-cache build-base git
WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
ENV CGO_ENABLED=1
RUN go build -trimpath -ldflags="-s -w" -o /out/Alita_Robot .

# Keep the runtime image small while retaining the C runtime needed by
# go-sqlite3, CA certificates for Telegram/API connections, and timezone data.
FROM alpine:3.22 AS runtime

RUN apk add --no-cache ca-certificates tzdata libgcc \
    && addgroup -S app \
    && adduser -S -G app app

WORKDIR /app
COPY --from=builder /out/Alita_Robot /app/Alita_Robot

USER app
EXPOSE 8080
ENTRYPOINT ["/app/Alita_Robot"]
