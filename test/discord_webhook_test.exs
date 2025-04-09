defmodule DiscordWebhookTest do
  use ExUnit.Case
  doctest DiscordWebhook

  test "greets the world" do
    assert DiscordWebhook.hello() == :world
  end
end
