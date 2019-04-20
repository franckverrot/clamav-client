ARG RUBY_VERSION
FROM ruby:${RUBY_VERSION}-stretch
LABEL maintainer="franck@verrot.fr"

WORKDIR /clamav-client
ADD Gemfile /clamav-client
ADD clamav-client.gemspec /clamav-client

RUN apt-get update -qq && \
      apt-get install -y clamav-daemon clamav-freshclam clamav-unofficial-sigs && \
      freshclam && \
      bundle

ENTRYPOINT ["./start.sh"]

ADD . /clamav-client