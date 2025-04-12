defmodule DiscordWebhook do
  @moduledoc """
  Documentation for `DiscordWebhook`.
  """

  alias DiscordWebhook.Endpoint
  alias DiscordWebhook.Request

  @doc """
  Executes Webhook.

  ### Examples

  ```elixir
  alias DiscordWebhook.{Endpoint, Request}

  webhook_id = System.fetch_env!("DISCORD_WEBHOOK_ID")
  webhook_token = System.fetch_env!("DISCORD_WEBHOOK_TOKEN")
  endpoint = Endpoint.new(webhook_id, webhook_token)
  # or
  endpoint = Endpoint.new({:system, "DISCORD_WEBHOOK_ID"}, {:system, "DISCORD_WEBHOOK_TOKEN"})

  request = Request.new() |> Request.set_content("Hello")
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
