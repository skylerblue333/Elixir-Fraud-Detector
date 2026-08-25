ExUnit.start()

defmodule SkyFraudTest do
  use ExUnit.Case, async: true

  test "low-risk inputs remain advisory and deterministic" do
    input = %{
      "amount_minor" => 12_500,
      "transactions_last_hour" => 1,
      "country" => "us",
      "card_present" => true,
      "trusted_device" => true
    }

    assert {:ok, %{score: 0, band: "low", signals: [], decision: "advisory_only"}} = SkyFraud.evaluate(input)
    assert SkyFraud.evaluate(input) == SkyFraud.evaluate(input)
  end

  test "multiple risk signals accumulate and score is capped" do
    input = %{
      "amount_minor" => 2_000_000,
      "transactions_last_hour" => 20,
      "country" => "ZZ",
      "card_present" => false,
      "trusted_device" => false
    }

    assert {:ok, result} = SkyFraud.evaluate(input)
    assert result.score == 100
    assert result.band == "review"
    assert Enum.map(result.signals, & &1.id) == ["high_amount", "high_velocity", "unlisted_country", "card_not_present", "untrusted_device"]
  end

  test "bounded validation rejects malformed inputs" do
    assert {:error, _} = SkyFraud.evaluate(%{"amount_minor" => -1})
    assert {:error, _} = SkyFraud.evaluate(%{
      "amount_minor" => 1,
      "transactions_last_hour" => 1,
      "country" => "USA",
      "card_present" => true,
      "trusted_device" => true
    })
  end
end
