# syntax=docker/dockerfile:1

FROM ruby:3.2.2

# ✅ Install dependencies (MySQL client dev headers for mysql2 gem)
RUN apt-get update -qq && \
    apt-get install -y \
      build-essential \
      libmariadb-dev-compat \
      libmariadb-dev \
      nodejs \
      yarn \
      chromium \
      chromium-driver && \
    rm -rf /var/lib/apt/lists/*


WORKDIR /app

COPY Gemfile Gemfile.lock ./

# ✅ Install gems including test group (RSpec + Cucumber)
RUN bundle config set --local with 'development test' && \
    bundle install

COPY . .

RUN chmod +x bin/*

EXPOSE 3000

CMD ["bash", "-c", "bin/rails db:prepare && bin/rails server -b 0.0.0.0 -p 3000"]
