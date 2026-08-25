defmodule SkyFraud do
  @moduledoc "Deterministic transaction risk-rule evaluation."

  @max_amount_minor 100_000_000_000
  @max_velocity 10_000
  @countries MapSet.new(~w[US CA GB AU NZ JP SG DE FR ES IT NL SE NO DK FI IE CH AT BE PT])

  @type signal :: %{id: String.t(), points: non_neg_integer(), reason: String.t()}

  @spec evaluate(map()) :: {:ok, map()} | {:error, String.t()}
  def evaluate(input) when is_map(input) do
    with {:ok, amount} <- integer(input, "amount_minor", 0, @max_amount_minor),
         {:ok, velocity} <- integer(input, "transactions_last_hour", 0, @max_velocity),
         {:ok, country} <- country(input),
         {:ok, card_present} <- boolean(input, "card_present", false),
         {:ok, trusted_device} <- boolean(input, "trusted_device", false) do
      signals =
        []
        |> maybe_signal(amount >= 1_000_000, "high_amount", 35, "amount is at least 10,000 major currency units at 2-decimal scale")
        |> maybe_signal(velocity >= 10, "high_velocity", 30, "ten or more transactions were reported in the last hour")
        |> maybe_signal(not MapSet.member?(@countries, country), "unlisted_country", 20, "country is outside the built-in demonstration allowlist")
        |> maybe_signal(not card_present, "card_not_present", 10, "transaction is marked card-not-present")
        |> maybe_signal(not trusted_device, "untrusted_device", 15, "device is not marked trusted")
        |> Enum.reverse()

      score = signals |> Enum.map(& &1.points) |> Enum.sum() |> min(100)
      band = if score >= 60, do: "review", else: if(score >= 30, do: "elevated", else: "low")

      {:ok, %{score: score, band: band, signals: signals, decision: "advisory_only"}}
    end
  end

  def evaluate(_), do: {:error, "input must be a map"}

  defp integer(input, key, min, max) do
    case Map.get(input, key) do
      value when is_integer(value) and value >= min and value <= max -> {:ok, value}
      _ -> {:error, "#{key} must be an integer between #{min} and #{max}"}
    end
  end

  defp country(input) do
    case Map.get(input, "country") do
      value when is_binary(value) ->
        value = value |> String.trim() |> String.upcase()
        if Regex.match?(~r/^[A-Z]{2}$/, value), do: {:ok, value}, else: {:error, "country must be a two-letter code"}
      _ -> {:error, "country must be a two-letter code"}
    end
  end

  defp boolean(input, key, default) do
    case Map.get(input, key, default) do
      value when is_boolean(value) -> {:ok, value}
      _ -> {:error, "#{key} must be boolean"}
    end
  end

  defp maybe_signal(signals, true, id, points, reason), do: [%{id: id, points: points, reason: reason} | signals]
  defp maybe_signal(signals, false, _id, _points, _reason), do: signals
end

defmodule SkyFraud.CLI do
  @moduledoc false

  def main(args) do
    case args do
      [amount, velocity, country, card_present, trusted_device] ->
        input = %{
          "amount_minor" => parse_integer!(amount, "amount_minor"),
          "transactions_last_hour" => parse_integer!(velocity, "transactions_last_hour"),
          "country" => country,
          "card_present" => parse_boolean!(card_present, "card_present"),
          "trusted_device" => parse_boolean!(trusted_device, "trusted_device")
        }

        case SkyFraud.evaluate(input) do
          {:ok, result} -> IO.puts(format(result))
          {:error, error} -> fail(error)
        end

      _ -> fail("usage: sky_fraud <amount_minor> <transactions_last_hour> <country> <card_present> <trusted_device>")
    end
  end

  defp parse_integer!(value, field) do
    case Integer.parse(value) do
      {number, ""} -> number
      _ -> fail("#{field} must be an integer")
    end
  end

  defp parse_boolean!("true", _field), do: true
  defp parse_boolean!("false", _field), do: false
  defp parse_boolean!(_value, field), do: fail("#{field} must be true or false")

  defp format(result) do
    signal_ids = result.signals |> Enum.map(& &1.id) |> Enum.join(",")
    "score=#{result.score} band=#{result.band} decision=#{result.decision} signals=#{signal_ids}"
  end

  defp fail(message) do
    IO.puts(:stderr, "error: #{message}")
    System.halt(2)
  end
end
