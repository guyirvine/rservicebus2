FROM ruby:2.5.6-alpine

MAINTAINER Guy Irvine <guy@guyirvine.com>

RUN mkdir -p /opt/project/
RUN mkdir -p /tmp/saga/

RUN apk add g++ make

RUN echo "Install required" \
  && gem install bundler fluiddb2 uuidtools rservicebus2

COPY . /opt/project/

#USER fpuser

WORKDIR /opt/project/

RUN bundle install

EXPOSE 4570

ENV APPNAME=Project

ENTRYPOINT ["rservicebus2"]
