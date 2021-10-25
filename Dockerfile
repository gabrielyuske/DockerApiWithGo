FROM golang:1.16 as base

FROM base as dev

RUN curl -sSfL https://raw.githubusercontent.com/cosmtrek/air/master/install.sh | sh -s -- -b $(go env GOPATH)/bin

WORKDIR /opt/app/api
CMD ["air"]

FROM base as built

WORKDIR /go/app/api
COPY . .

ENV CGO_ENABLED=0

RUN go get -d -v ./...
RUN go build -o /tmp/api-server ./*.go

FROM busybox

COPY --from=built /tmp/api-server /usr/bin/api-server
CMD ["api-server", "start"]

# A primeira nova etapa do nosso contêiner constrói nosso binário usando nosso estágio para garantir 
#    que tenhamos um ambiente Go para realmente compilar o projeto.base

# A próxima (e final) etapa é uma imagem de câmera movimentada minimalista que copia em nosso binário e coloca-a 
#   em uma pasta que está nos recipientes .