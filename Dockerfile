FROM docker.io/ruby:3.3-slim-bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential libc-dev sqlite3 nodejs npm && \
    adduser --disabled-password --uid 1001 --home /app app && \
    mkdir -p /app && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ckeditor5.gemspec ./
COPY lib/ lib/
COPY sandbox/ sandbox/

RUN chown -R app:app /app

USER app

RUN gem install bundler && \
    bundle config set without 'development test' && \
    bundle install

ENV RAILS_ENV=production
ENV PORT=3002

RUN cd sandbox/ && bundle exec rake assets:precompile

CMD ["sh", "-c", "cd sandbox/ && bundle exec rails s -p ${PORT} -b '0.0.0.0'"]

