FROM ruby:3.2.2

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN apt-get update && apt-get install -y iputils-ping

RUN gem install bundler

RUN bundle install

COPY . .