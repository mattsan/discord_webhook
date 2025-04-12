defmodule DiscordWebhook.Endpoint do
  @moduledoc """
  A struct of Discord endpoint.
  """

  defstruct [:base, :id, :token]

  @type t() :: %__MODULE__{
          base: URI.t(),
          id: binary(),
          token: binary()
        }
  @type endpoint_config() :: binary() | {:system, binary()}

  @base URI.new!("https://discord.com/api/webhooks")

  @doc """
  Returns a new Endpoint struct.

  ### Examples

  ```elixir
  # from binaries
  endpoint = Endpoint.new("foo", "bar")
  ```

  ```elixir
  # from environment variables
  endpoint = Endpoint.new({:system, "WEBHOOK_ID"}, {:system, "WEBHOOK_TOKEN"})
  ```
  """
  @spec new(endpoint_config(), endpoint_config()) :: t()
  def new(id, token) when is_binary(id) and is_binary(token) do
    %__MODULE__{base: @base, id: id, token: token}
  end

  def new({:system, id_key}, token) do
    new(System.fetch_env!(id_key), token)
  end

  def new(id, {:system, token_key}) do
    new(id, System.fetch_env!(token_key))
  end

  @doc """
  Returns the endpoint URL to execute Webhook.

  ### Examples

  ```elixir
  iex> Endpoint.new("foo", "bar")
  ...> |> Endpoint.url_to_execute()
  "https://discord.com/api/webhooks/foo/bar"
  ```
  """
  @spec url_to_execute(t()) :: binary()
  def url_to_execute(%__MODULE__{base: base, id: id, token: token}) do
    path = Path.join(["/", id, token])

    base
    |> URI.append_path(path)
    |> URI.to_string()
  end
end
