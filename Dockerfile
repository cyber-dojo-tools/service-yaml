FROM alpine:latest
LABEL maintainer=jon@jaggersoft.com

RUN apk --update --upgrade --no-cache add bash
COPY . /app

ENTRYPOINT [ "/app/main.sh" ]
