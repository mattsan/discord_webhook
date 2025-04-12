defmodule DiscordWebhook.EndpointTest do
  use ExUnit.Case
  alias DiscordWebhook.Endpoint

  doctest Endpoint

  defp setup_env({key, value}) do
    prev_env = System.fetch_env(key)
    on_exit(fn -> cleanup_env(key, prev_env) end)

    :ok = System.put_env(key, value)
  end

  defp cleanup_env(key, {:ok, value}), do: System.put_env(key, value)
  defp cleanup_env(key, _), do: System.delete_env(key)

  setup(context) do
    env = get_in(context, [:env])
    if !is_nil(env), do: Enum.each(env, &setup_env/1)

    :ok
  end

  describe "new/2" do
    test "文字列で指定した ID とトークンが格納される" do
      assert %Endpoint{id: "FOO", token: "BAR"} = Endpoint.new("FOO", "BAR")
    end

    @tag env: [{"WEBHOOK_ID", "FOO"}, {"WEBHOOK_TOKEN", "BAR"}]
    test "環境変数で指定した ID とトークンが格納される" do
      assert %Endpoint{id: "FOO", token: "BAR"} =
               Endpoint.new({:system, "WEBHOOK_ID"}, {:system, "WEBHOOK_TOKEN"})
    end
  end
end
