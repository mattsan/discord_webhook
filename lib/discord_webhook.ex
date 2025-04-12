defmodule DiscordWebhook do
  @moduledoc """
  Discord webhook.
  """

  alias DiscordWebhook.Endpoint
  alias DiscordWebhook.Request

  @doc """
  Executes Webhook.

  see https://discord.com/developers/docs/resources/webhook#execute-webhook

  ### Examples

  ```elixir
  alias DiscordWebhook.{Endpoint, Request}

  # give ID and TOKEN immediately
  endpoint = Endpoint.new("012345678901234567", "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxx-xxxxxxxxx-xxxxx")

  # or give them via environment variables
  endpoint = Endpoint.new({:system, "DISCORD_WEBHOOK_ID"}, {:system, "DISCORD_WEBHOOK_TOKEN"})

  # build a request
  request =
    Request.new()
    |> Request.set_content("Hello")

  # execute webhook
  DiscordWebhook.execute(endpoint, request)
  ```elixir
  """
  @spec execute(Endpoint.t(), Request.t()) :: {:ok, Req.Response.t()} | {:error, Exception.t()}
  def execute(%Endpoint{} = endpoint, %Request{} = request) do
    Req.new(
      method: :post,
      url: Endpoint.url_to_execute(endpoint),
      form_multipart: Request.to_form_multipart(request)
    )
    |> Req.request()
  end
end
