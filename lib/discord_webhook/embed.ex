defmodule DiscordWebhook.Embed do
  @moduledoc """
  A struct of Embed Object in requst parameters.

  see https://discord.com/developers/docs/resources/message#embed-object
  """

  @derive JSON.Encoder
  defstruct [:title, :description, :timestamp, :color, :footer]

  @type timestamp() :: binary | Date.t() | DateTime.t() | NaiveDateTime.t()
  @type color() :: 0..0xFFFFFF
  @type footer() :: %{
          text: binary() | nil,
          icon_url: binary() | nil
        }
  @type t() :: %__MODULE__{
          title: binary() | nil,
          description: binary() | nil,
          timestamp: timestamp() | nil,
          color: color() | nil,
          footer: footer() | nil
        }

  defguardp is_timestamp(term)
            when is_binary(term) or
                   is_struct(term, Date) or
                   is_struct(term, DateTime) or
                   is_struct(term, NaiveDateTime)

  defguardp is_color(term) when is_integer(term) and 0 <= term and term <= 0xFFFFFF

  @doc false
  @spec to_timestamp(timestamp()) :: binary()
  def to_timestamp(term) when is_binary(term), do: term
  def to_timestamp(term) when is_struct(term, Date), do: Date.to_iso8601(term)
  def to_timestamp(term) when is_struct(term, DateTime), do: DateTime.to_iso8601(term)
  def to_timestamp(term) when is_struct(term, NaiveDateTime), do: NaiveDateTime.to_iso8601(term)

  @doc """
  Creates a new blank embed object.
  """
  @spec new :: t()
  def new do
    %__MODULE__{}
  end

  @doc """
  Sets title to the embed object.

  ### Examples

  ```elixir
  Embed.new()
  |> Embed.set_title("something")
  ```
  """
  @spec set_title(t(), binary()) :: t()
  def set_title(%__MODULE__{} = embed, title) when is_binary(title) do
    %{embed | title: title}
  end

  @doc """
  Sets description to the embed object.

  ### Examples

  ```elixir
  Embed.new()
  |> Embed.set_description("something")
  ```
  """
  @spec set_description(t(), binary()) :: t()
  def set_description(%__MODULE__{} = embed, description) when is_binary(description) do
    %{embed | description: description}
  end

  @doc """
  Sets timestamp to the embed object.

  ### Examples

  ```elixir
  Embed.new()
  |> Embed.set_timestamp("2025-04-12T12:34:56Z")
  ```

  ```elixir
  Embed.new()
  |> Embed.set_timestamp(~D[2025-04-12])
  ```

  ```elixir
  Embed.new()
  |> Embed.set_timestamp(~U[2025-04-12T12:34:56Z])
  ```

  ```elixir
  Embed.new()
  |> Embed.set_timestamp(~N[2025-04-12T12:34:56])
  ```
  """
  @spec set_timestamp(t(), timestamp()) :: t()
  def set_timestamp(%__MODULE__{} = embed, timestamp) when is_timestamp(timestamp) do
    %{embed | timestamp: to_timestamp(timestamp)}
  end

  @doc """
  Sets color to the embed object.

  ### Examples

  ```elixir
  Embed.new()
  |> Embed.set_color(0xFFFF00) # Red 0xFF, Green 0xFF, Blue 0x00 = Yellow
  ```
  """
  @spec set_color(t(), color()) :: t()
  def set_color(%__MODULE__{} = embed, color) when is_color(color) do
    %{embed | color: color}
  end

  @doc """
  Sets footer to the embed object.

  ### Examples

  ```elixir
  Embed.new()
  |> Embed.set_footer("something")
  ```

  ```elixir
  Embed.new()
  |> Embed.set_footer("something", "https://example.com/footer-icon.png")
  ```
  """
  @spec set_footer(t(), binary(), binary() | nil) :: t()
  def set_footer(%__MODULE__{} = embed, text, icon_url \\ nil)
      when is_binary(text) and (is_binary(icon_url) or is_nil(icon_url)) do
    %{embed | footer: %{text: text, icon_url: icon_url}}
  end
end
