defmodule DiscordWebhook.Endpoint do
  defstruct [:base, :webhook_id, :webhook_token]

  @type t() :: %__MODULE__{
          base: URI.t(),
          webhook_id: binary(),
          webhook_token: binary()
        }

  @base URI.new!("https://discord.com/api/webhooks")

  @spec new(binary(), binary()) :: t()
  def new(webhook_id, webhook_token) do
    %__MODULE__{base: @base, webhook_id: webhook_id, webhook_token: webhook_token}
  end

  @spec url(t()) :: binary()
  def url(%__MODULE__{base: base, webhook_id: webhook_id, webhook_token: webhook_token}) do
    path = Path.join(["/", webhook_id, webhook_token])

    base
    |> URI.append_path(path)
    |> URI.to_string()
  end
end
