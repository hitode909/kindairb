FROM ruby:2.4.0

RUN gem install kindai

VOLUME /workdir
WORKDIR /workdir

ENTRYPOINT ["kindai.rb"]
