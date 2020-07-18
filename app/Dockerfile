FROM alpine:latest
LABEL maintainer=jon@jaggersoft.com

RUN apk --update --upgrade --no-cache add bash
COPY . /app

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ENTRYPOINT [ "/app/service-yaml.sh" ]
