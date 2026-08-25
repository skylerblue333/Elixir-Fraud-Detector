# Contributing to SKYCOIN4444

## Development Setup

Use Elixir 1.18 / OTP 27 and run the same checks enforced by CI:

```bash
mix format --check-formatted
mix compile --warnings-as-errors
mix test
mix escript.build
./sky_fraud 2000000 20 ZZ false false
```

For container verification:

```bash
docker build -t sky-fraud-rules:local .
test "$(docker run --rm --entrypoint /usr/bin/id sky-fraud-rules:local -u)" != "0"
docker run --rm sky-fraud-rules:local 12500 1 US true true
```

## Code Style

- Keep the component dependency-light and deterministic.
- Run `mix format` before committing.
- Compile with warnings treated as errors.
- Add ExUnit coverage for behavioral changes.
- Preserve the advisory-only product boundary; do not present risk signals as proof of fraud or automatic consequential decisions.

## Pull Requests

1. Create a focused feature branch.
2. Make bounded changes with truthful product boundaries.
3. Run the format, compile, test, escript, and container checks above.
4. Submit a PR describing supported behavior and remaining limitations.

## License

MIT
