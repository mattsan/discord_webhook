defmodule DiscordWebhook.Request do
  defstruct payload: %DiscordWebhook.Payload{}, files: []

  alias DiscordWebhook.Embed
  alias DiscordWebhook.Payload

  @type t() :: %__MODULE__{
          payload: Payload.t(),
          files: [file]
        }
  @type file() :: {filename :: binary(), body :: binary()}

  @spec new :: t()
  def new do
    %__MODULE__{}
  end

  @spec set_content(t(), binary()) :: t()
  def set_content(%__MODULE__{} = request, content) when is_binary(content) do
    update_payload(request, :content, content)
  end

  @spec set_username(t(), binary()) :: t()
  def set_username(%__MODULE__{} = request, username) when is_binary(username) do
    update_payload(request, :username, username)
  end

  @spec set_avatar_url(t(), binary()) :: t()
  def set_avatar_url(%__MODULE__{} = request, avatar_url) when is_binary(avatar_url) do
    update_payload(request, :avatar_url, avatar_url)
  end

  @spec embed(t(), Embed.t()) :: t()
  def embed(%__MODULE__{} = request, %Embed{} = embed) do
    update_payload(request, :embeds, request.payload.embeds ++ [embed])
  end

  @spec embed(t(), (Embed.t() -> Embed.t())) :: t()
  def embed(%__MODULE__{} = request, fun) when is_function(fun) do
    update_payload(request, :embeds, request.payload.embeds ++ [fun.(Embed.new())])
  end

  @spec attach_file(t(), binary(), binary(), binary()) :: t()
  def attach_file(%__MODULE__{} = request, description, filename, body)
      when is_binary(description) and is_binary(filename) and is_binary(body) do
    attachments = request.payload.attachments ++ [{description, filename}]

    request
    |> update_payload(:attachments, attachments)
    |> Map.update!(:files, fn files -> files ++ [{filename, body}] end)
  end

  defp update_payload(request, key, value) do
    %{request | payload: %{request.payload | key => value}}
  end

  defdelegate embed_title(embed, title), to: Embed, as: :set_title
  defdelegate embed_description(embed, description), to: Embed, as: :set_description
  defdelegate embed_timestamp(embed, timestamp), to: Embed, as: :set_timestamp
  defdelegate embed_color(embed, color), to: Embed, as: :set_color
  defdelegate embed_footer(embed, text, icon_url), to: Embed, as: :set_footer

  @doc false
  @spec to_parts(t()) :: list()
  def to_parts(%__MODULE__{} = request) do
    files =
      request.files
      |> Enum.with_index(fn {filename, body}, index ->
        file_part(index, filename, body)
      end)

    [payload_part(request.payload) | files]
  end

  defp payload_part(%Payload{} = payload) do
    payload_json =
      JSON.encode!(
        Map.update!(payload, :attachments, fn attachments ->
          Enum.with_index(attachments, fn {description, filename}, id ->
            %{id: id, description: description, filename: filename}
          end)
        end)
      )

    {"payload_json", payload_json}
  end

  defp file_part(index, filename, body) do
    {
      "files[#{index}]",
      {
        body,
        [
          filename: filename,
          content_type: :mimerl.extension(filename)
        ]
      }
    }
  end
end
