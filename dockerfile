FROM alpine:3.19

RUN apk add --no-cache bash grep gawk coreutils

WORKDIR /app

COPY . /app

RUN chmod +x *.sh scripts/*.sh

CMD ["sh", "/app/run_pipeline.sh"]
