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

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
ENV RAILS_ENV=production
ENV PORT=3002
ENV WEB_CONCURRENCY=3
ENV RAILS_MAX_THREADS=5

RUN cd sandbox/ && bundle exec rake assets:precompile

# Add these lines to create required directories
RUN mkdir -p sandbox/tmp/pids sandbox/log
RUN chown -R app:app sandbox/tmp sandbox/log

CMD ["sh", "-c", "cd sandbox/ && bundle exec puma -C config/puma.rb"]

