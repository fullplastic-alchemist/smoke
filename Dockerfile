ARG BUILDER_IMAGE="hexpm/elixir:1.14.2-erlang-25.0.4-debian-bullseye-20220801-slim"
ARG RUNNER_IMAGE="debian:bullseye-20220801-slim"

FROM ${BUILDER_IMAGE} as builder

# set build ENV
ENV MIX_ENV="prod"

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install mix dependencies
COPY mix.exs ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

# Compile the release
COPY lib lib

RUN mix compile

RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/prod/rel ./

CMD /app/smoke/bin/smoke start