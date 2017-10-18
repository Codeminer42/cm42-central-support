from ruby:2.3.1

env DEBIAN_FRONTEND noninteractive

copy . /tmp/cm42-central-support

run sed -i '/deb-src/d' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y build-essential postgresql-client && \
  gem install bundler && cd /tmp/cm42-central-support/spec/support/rails_app && bundle install

workdir /app
