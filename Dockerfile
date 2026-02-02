ARG RUBY_VERSION=3.4
FROM ruby:${RUBY_VERSION}

ARG BUNDLER_VERSION="2.6.7"
ARG NODE_VERSION=14
ARG BUILD_DATE=
ARG CVS_REF=

LABEL maintainer="DevEx Team <squad_devex@apptweak.com>"
LABEL org.opencontainers.image.source https://github.com/apptweak/pronto-ruby
LABEL org.opencontainers.image.title="AppTweak Pronto Ruby Runner"
LABEL org.opencontainers.image.description="GitHub Action for running Pronto code review automation for Ruby projects"
LABEL org.opencontainers.image.source="https://github.com/apptweak/pronto-ruby"
LABEL org.opencontainers.image.url="https://github.com/apptweak/pronto-ruby"
LABEL org.opencontainers.image.vendor="AppTweak"
LABEL org.opencontainers.image.version=${CVS_REF}
LABEL org.opencontainers.image.created=${BUILD_DATE}

RUN apt-get update && apt-get install -y curl

RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  build-essential \
  cmake \
  git \
  pkg-config \
  openssl \
  libssl-dev \
  libzstd-dev \
  libz-dev \
  && rm -rf /var/lib/apt/lists/*

# Make sure to use bash with pipefail in case something
# fails while being piped to another command in the docker-build
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN gem install bundler --version "${BUNDLER_VERSION}"

WORKDIR /runner

COPY Gemfile* .bundle ./

RUN bundle install --retry 4

ENV BUNDLE_GEMFILE=/runner/Gemfile

COPY . ./

WORKDIR /data

ENTRYPOINT ["/runner/pronto"]
