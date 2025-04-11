defmodule DiscordWebhook.Embed do
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

  @spec new :: t()
  def new do
    %__MODULE__{}
  end

  @spec set_title(t(), binary()) :: t()
  def set_title(%__MODULE__{} = embed, title) when is_binary(title) do
    %{embed | title: title}
  end

  @spec set_description(t(), binary()) :: t()
  def set_description(%__MODULE__{} = embed, description) when is_binary(description) do
    %{embed | description: description}
  end

  @spec set_timestamp(t(), timestamp()) :: t()
  def set_timestamp(%__MODULE__{} = embed, timestamp) when is_timestamp(timestamp) do
    %{embed | timestamp: timestamp}
  end

  @spec set_color(t(), color()) :: t()
  def set_color(%__MODULE__{} = embed, color) when is_color(color) do
    %{embed | color: color}
  end

  @spec set_footer(t(), binary(), binary()) :: t()
  def set_footer(%__MODULE__{} = embed, text, icon_url) do
    %{embed | footer: %{text: text, icon_url: icon_url}}
  end
end
