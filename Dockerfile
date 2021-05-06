FROM python:3.9-alpine
LABEL maintainer="Harry Lee <harry@melio.co.za>"
LABEL description="An utility image that is meant to be used for ansible + terraform deployments."

RUN apk upgrade --update

ENV TIME_ZONE Africa/Johannesburg
RUN apk add tzdata && \
    echo "$TIME_ZONE" > /etc/timezone

RUN apk add \
    build-base \
    libffi-dev \
    libressl-dev \
    openssh-client \
    jq \
    groff \
    tar \
    git \
    gcc \
    musl-dev \
    python3-dev \

ENV ANSIBLE_VERSION 2.11.0
RUN pip install --upgrade pip \
    pyopenssl \
    ansible-core=="$ANSIBLE_VERSION" \
    awscli \
    yq

COPY requirements.txt .
RUN pip install -r requirements.txt && \
    rm -fr requirements.txt

ENV TERRAFORM_VERSION 0.15.1

ADD https://releases.hashicorp.com/terraform/"$TERRAFORM_VERSION"/terraform_"$TERRAFORM_VERSION"_linux_amd64.zip /usr/local/bin/terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
RUN unzip -q -d /usr/local/bin /usr/local/bin/terraform_"$TERRAFORM_VERSION"_linux_amd64.zip && \
    chmod +x /usr/local/bin/terraform && \
    rm -f /usr/local/bin/terraform_"$TERRAFORM_VERSION"_linux_amd64.zip

ENV GO_VERSION 1.13.4
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

ADD https://dl.google.com/go/go"$GO_VERSION".linux-amd64.tar.gz /usr/local/go.tar.gz
RUN tar xfz /usr/local/go.tar.gz && \
    rm -f go.tar.gz && \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

ENV KUBECTL_VERSION 1.19.10
ADD https://storage.googleapis.com/kubernetes-release/release/v"$KUBECTL_VERSION"/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

