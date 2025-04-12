defmodule DiscordWebhook.Payload do
  @moduledoc """
  A struct of requst payload and construction functions.
  """

  @derive JSON.Encoder
  defstruct [:content, :username, :avatar_url, attachments: [], embeds: []]

  @type t() :: %__MODULE__{
          content: binary(),
          username: binary() | nil,
          avatar_url: binary() | nil,
          attachments: [attachment()] | nil,
          embeds: [DiscordWebhook.Embed.t()] | nil
        }
  @type attachment() :: {description :: binary(), filename :: binary()}

  @doc """
  Creates a new blank payload.
  """
  @spec new :: t()
  def new do
    %__MODULE__{}
  end
end
