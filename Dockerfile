FROM alpine:latest
RUN apk add --no-cache go git
RUN git clone https://github.com/GoogleCloudPlatform/terraformer /root/terraformer
RUN cd /root/terraformer && go mod download && go run build/main.go datadog  

FROM alpine:latest
COPY --from=0 /root/terraformer/terraformer-datadog /root
RUN apk add --no-cache terraform
COPY datadog-provider.tf /root
RUN cd /root && terraform init
WORKDIR /root/


ENV PATH=$PATH:/root:
ENTRYPOINT [ "terraformer-datadog", "import", "datadog"  ]
