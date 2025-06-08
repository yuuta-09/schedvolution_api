FROM ruby:3.1.2
ARG APP_NAME=myapp
ARG USER_NAME=myuser
ARG RUBYGEMS_VERSION=3.3.20
ENV TZ=Asia/Tokyo

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs vim

RUN mkdir /myapp
WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

RUN gem update --system ${RUBYGEMS_VERSION} && \
  bundle install
RUN bundle install
RUN sed -i '/require "fiber"/a require "logger"' /usr/local/bundle/gems/activesupport-6.1.7.10/lib/active_support/logger_thread_safe_level.rb
ADD . /myapp
