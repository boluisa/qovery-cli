FROM golang:1.19 as builder

# Set the working directory within the container
WORKDIR /app

# Copy go.mod and go.sum files to the container's working directory
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the source code to the container's working directory
COPY . .

# Build the Go application
RUN go build -o qovery

FROM debian:bookworm-slim as runner

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

WORKDIR /app

# make the exec.sh file executable
COPY docker/ docker
RUN chmod +x ./docker/exec.sh

COPY --from=builder /app/qovery /app/qovery

# Add the /app directory to the PATH environment variable
ENV PATH="/app:${PATH}"

ENTRYPOINT ["sh", "./docker/exec.sh"]
