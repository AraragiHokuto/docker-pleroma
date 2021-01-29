FROM elixir:1.11.2-alpine

ENV UID=911 GID=911 \
    MIX_ENV=prod

ARG PLEROMA_VER=develop

RUN apk -U upgrade \
    && apk add --no-cache \
    build-base \
    cmake \
    git \
    file-dev

RUN addgroup -g ${GID} pleroma \
    && adduser -h /pleroma -s /bin/sh -D -G pleroma -u ${UID} pleroma

USER pleroma

WORKDIR /pleroma

RUN git clone -b ${PLEROMA_VER} https://git.pleroma.social/pleroma/pleroma.git /pleroma --depth=1

COPY config/secret.exs /pleroma/config/prod.secret.exs

RUN mix local.rebar --force \
    && mix local.hex --force \
    && mix deps.get \
    && mix compile

# This is for installing soapbox, or some other frontends.
# COPY instance/* /pleroma/priv/static/

VOLUME /pleroma/uploads/

CMD ["mix", "phx.server"]
