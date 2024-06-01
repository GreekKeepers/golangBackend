FROM golang:latest

WORKDIR /app

COPY go.mod  go.sum ./

RUN go mod download

COPY . .

RUN go build -o main

EXPOSE 8181

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -a -installsuffix cgo -o app cmd/app/main.go

CMD ["./app"]
