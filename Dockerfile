# STEP 1 - Build release compiler container
FROM elixir:1.18-otp-27-alpine AS builder

ENV APP_NAME=ivhs_broker \
    APP_VERSION=0.1.0 \
    MIX_ENV=prod

WORKDIR /ivhs_broker

# Install build requirements
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache openssl-dev make build-base gcc git nodejs npm openssh

RUN mix local.rebar --force && \
    mix local.hex --force

RUN npm root -g
# Compile dependencies and application
COPY . .
RUN mix deps.get --only ${MIX_ENV}
RUN mix compile

RUN cd assets && npm ci
RUN mix assets.deploy

# Create a release
RUN mkdir -p /opt/build && \
    mix release && \
    cp -r _build/${MIX_ENV}/rel /opt/build

# STEP 2 - Build application container
FROM alpine:3.21

ARG APP_NAME
ENV APP_NAME=${APP_NAME}

ENV ROOT_FOLDER=/opt

# Update kernel and install runtime dependencies
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add bash \
        openssl \
        openssl-dev \
        libgcc \
        libstdc++ \
        sqlite

WORKDIR ${ROOT_FOLDER}

# Copy the OTP binary from the build step
COPY --from=builder /opt/build .

RUN ls .

RUN mkdir ${ROOT_FOLDER}/logs

# Create a non-root user
RUN adduser -D ivhs_broker && \
    chown -R ivhs_broker: ${ROOT_FOLDER}

USER ivhs_broker

ENTRYPOINT ["/opt/rel/ivhs_broker/bin/ivhs_broker"]
CMD ["start"]
