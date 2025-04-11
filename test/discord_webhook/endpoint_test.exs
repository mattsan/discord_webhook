defmodule DiscordWebhook.EndpointTest do
  use ExUnit.Case
  alias DiscordWebhook.Endpoint

  doctest Endpoint

  defp setup_env(context) do
    env = get_in(context, [:env])

    if !is_nil(env) do
      Enum.each(env, fn {key, value} ->
        prev_env = System.fetch_env(key)

        :ok = System.put_env(key, value)

        on_exit(fn ->
          case prev_env do
            {:ok, value} ->
              System.put_env(key, value)

            _ ->
              System.delete_env(key)
          end
        end)
      end)
    end

    :ok
  end

  setup :setup_env

  describe "new/2" do
    test "文字列で指定した ID とトークンが格納されること" do
      assert %Endpoint{id: "FOO", token: "BAR"} = Endpoint.new("FOO", "BAR")
    end

    @tag env: [{"WEBHOOK_ID", "FOO"}, {"WEBHOOK_TOKEN", "BAR"}]
    test "環境変数で指定した ID とトークンが格納されること" do
      assert %Endpoint{id: "FOO", token: "BAR"} =
               Endpoint.new({:system, "WEBHOOK_ID"}, {:system, "WEBHOOK_TOKEN"})
    end
  end
end
