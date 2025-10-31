# syntax=docker/dockerfile:1

FROM ruby:3.2.2

RUN apt-get update -qq && \
    apt-get install -y build-essential libmariadb-dev nodejs yarn && \
    rm -rf /var/lib/apt/lists/*


WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bash", "-c", "bin/rails db:prepare && bin/rails server -b 0.0.0.0 -p 3000"]
