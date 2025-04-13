defmodule DiscordWebhook.Request do
  @moduledoc """
  A struct of requst and construction functions.

  For more information, see the Discord Webhook document.
  - https://discord.com/developers/docs/resources/webhook#execute-webhook-jsonform-params

  ### Examples

  ```elixir
  request =
    Request.new()
    |> Request.set_content("Quos molestiae voluptates illo.")
    |> Request.set_username("voluptas")
    |> Request.set_avatar_url("https://example.com/avatar.png")
    |> Request.add_embed(
      title: "Rerum eum dolorem qui nihil autem.",
      description: "Placeat officia qui fuga ut.",
      timestamp: NaiveDateTime.utc_now(),
      color: 0xFFFF00,
      footer: {"magni", "https://example.com/footer-icon.png"}
    )
    |> Request.attach_file("Expedita", "illo.jpg", File.read!("path/to/illo.jpg"))
    |> Request.attach_file("Dolores", "maiores.pdf", File.read!("path/to/maiores.pdf"))
    |> Request.set_poll(
      question: "Which do you like?",
      answers: ~w(foo bar baz),
      expiry: ~U[2025-04-12T12:34:56Z],
      allow_multiselect: true
    )
  ```
  """

  defstruct [:payload, :files]

  alias DiscordWebhook.Embed
  alias DiscordWebhook.Payload
  alias DiscordWebhook.Poll

  import Embed, only: [is_timestamp: 1, is_color: 1]

  @type t() :: %__MODULE__{
          payload: Payload.t(),
          files: [file]
        }
  @type file() :: {filename :: binary(), body :: binary()}

  @doc """
  Creates a new blank request.
  """
  @spec new :: t()
  def new do
    %__MODULE__{payload: Payload.new(), files: []}
  end

  @doc """
  Sets content to the request.

  ### Examples

  ```elixir
  Request.new()
  |> Request.set_content("the message contents")
  ```
  """
  @spec set_content(t(), binary()) :: t()
  def set_content(%__MODULE__{} = request, content) when is_binary(content) do
    update_payload(request, :content, content)
  end

  @doc """
  Sets username to the request.

  ### Examples

  ```elixir
  Request.new()
  |> Request.set_username("e.mattsan")
  ```
  """
  @spec set_username(t(), binary()) :: t()
  def set_username(%__MODULE__{} = request, username) when is_binary(username) do
    update_payload(request, :username, username)
  end

  @doc """
  Sets avatar URL to the request.

  ### Examples

  ```elixir
  Request.new()
  |> Request.set_avatar_url("https://example.com/avatar.png")
  ```
  """
  @spec set_avatar_url(t(), binary()) :: t()
  def set_avatar_url(%__MODULE__{} = request, avatar_url) when is_binary(avatar_url) do
    update_payload(request, :avatar_url, avatar_url)
  end

  @doc """
  Adds embed object to the request.

  Up to 10 Embed Objects can be embedded.

  ### Examples

  ```elixir
  embed =
    Embed.new()
    |> Embed.set_description("description")

  Request.new()
  |> Request.add_embed(embed)
  ```

  ```elixir
  Request.new()
  |> Request.add_embed(
    description: "description"
  )
  ```
  """
  @spec add_embed(t(), Embed.t() | keyword()) :: t()
  def add_embed(%__MODULE__{} = request, %Embed{} = embed) do
    update_payload(request, :embeds, request.payload.embeds ++ [embed])
  end

  def add_embed(%__MODULE__{} = request, fields) when is_list(fields) do
    embed =
      Enum.reduce(fields, Embed.new(), fn field, embed ->
        case field do
          {:title, title} when is_binary(title) ->
            Embed.set_title(embed, title)

          {:description, description} when is_binary(description) ->
            Embed.set_description(embed, description)

          {:timestamp, timestamp} when is_timestamp(timestamp) ->
            Embed.set_timestamp(embed, timestamp)

          {:color, color} when is_color(color) ->
            Embed.set_color(embed, color)

          {:footer, text} when is_binary(text) ->
            Embed.set_footer(embed, text)

          {:footer, {text}} when is_binary(text) ->
            Embed.set_footer(embed, text)

          {:footer, {text, icon_url}} when is_binary(text) and is_binary(icon_url) ->
            Embed.set_footer(embed, text, icon_url)
        end
      end)

    add_embed(request, embed)
  end

  @doc """
  Attach a file to the request.

  ### Examples

  ```elixir
  Request.new()
  |> Request.attach_file("sample image", "sample.jpg", File.read!("path/to/sample.jpg"))
  ```
  """
  @spec attach_file(t(), binary(), binary(), binary()) :: t()
  def attach_file(%__MODULE__{} = request, description, filename, body)
      when is_binary(description) and is_binary(filename) and is_binary(body) do
    attachments = request.payload.attachments ++ [{description, filename}]

    request
    |> update_payload(:attachments, attachments)
    |> Map.update!(:files, fn files -> files ++ [{filename, body}] end)
  end

  @doc """
  Sets a poll object to the request.

  ### Examples

  ```elixir
  poll =
    Poll.new()
    |> Poll.set_question("Which do you like?")
    |> Poll.add_answer("foo")
    |> Poll.add_answer("bar")
    |> Poll.add_answer("baz")
    |> Poll.set_expiry(~U[2025-04-12T12:34:56Z])
    |> Poll.allow_multiselect()

  Request.new()
  |> Request.set_poll(poll)
  ```

  ```elixir
  Request.new()
  |> Request.set_poll(
    question: "Which do you like?",
    answers: ~w(foo bar baz),
    expiry: ~U[2025-04-12T12:34:56Z],
    allow_multiselect: true
  )
  ```
  """
  @spec set_poll(t(), Poll.t() | keyword()) :: t()

  def set_poll(%__MODULE__{} = request, %Poll{} = poll) do
    request
    |> update_payload(:poll, poll)
  end

  def set_poll(%__MODULE__{} = request, fields) when is_list(fields) do
    poll =
      Enum.reduce(fields, Poll.new(), fn field, poll ->
        case field do
          {:question, question} when is_binary(question) ->
            Poll.set_question(poll, question)

          {:answers, answers} when is_list(answers) ->
            Enum.reduce(answers, poll, &Poll.add_answer(&2, &1))

          {:expiry, expiry} ->
            Poll.set_expiry(poll, expiry)

          {:allow_multiselect, true} ->
            Poll.allow_multiselect(poll)

          {:allow_multiselect, false} ->
            poll
        end
      end)

    request
    |> update_payload(:poll, poll)
  end

  defp update_payload(request, key, value) do
    %{request | payload: %{request.payload | key => value}}
  end

  @doc false
  @spec to_form_multipart(t()) :: list()
  def to_form_multipart(%__MODULE__{} = request) do
    files =
      request.files
      |> Enum.with_index(fn {filename, body}, id ->
        file_part(id, filename, body)
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

  defp file_part(id, filename, body) do
    {
      "files[#{id}]",
      {
        body,
        [
          filename: filename,
          content_type: mime_type_of(filename)
        ]
      }
    }
  end

  defp mime_type_of(filename) do
    :mimerl.filename(filename)
  end
end
