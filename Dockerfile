FROM hexpm/elixir:1.18.4-erlang-27.3-debian-bookworm-20250224-slim AS builder
WORKDIR /src
COPY mix.exs ./
COPY lib ./lib
RUN mix escript.build

FROM debian:bookworm-slim
RUN useradd --system --uid 10001 --no-create-home sky
COPY --from=builder /src/sky_fraud /usr/local/bin/sky_fraud
USER 10001:10001
ENTRYPOINT ["/usr/local/bin/sky_fraud"]
