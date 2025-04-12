defmodule DiscordWebhook.Request do
  @moduledoc """
  A struct of requst and construction functions.

  see https://discord.com/developers/docs/resources/webhook#execute-webhook-jsonform-params

  ### Examples

  ```elixir
  request =
    Request.new()
    |> Request.set_content("Quos molestiae voluptates illo.")
    |> Request.set_username("voluptas")
    |> Request.set_avatar_url("https://example.com/avatar.png")
    |> Request.embed(fn embed ->
      embed
      |> Request.embed_title("Rerum eum dolorem qui nihil autem.")
      |> Request.embed_description("Placeat officia qui fuga ut.")
      |> Request.embed_timestamp(NaiveDateTime.utc_now())
      |> Request.embed_color(0xFFFF00)
      |> Request.embed_footer("magni", "https://example.com/footer-icon.png")
    end)
    |> Request.attach_file("Expedita aut natus sunt explicabo sit nulla sequi minima.", "illo.jpg", File.read!("path/to/illo.jpg"))
    |> Request.attach_file("Dolores mollitia asperiores necessitatibus sint et voluptas.", "maiores.pdf", File.read!("path/to/maiores.pdf"))
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
  Sets embed object to the request.

  ### Examples

  ```elixir
  embed =
    Embed.new()
    |> Embed.set_description("description")

  Request.new()
  |> Request.embed(embed)
  ```

  ```elixir
  Request.new()
  |> Request.embed(fn embed ->
    embed
    |> Request.embed_description("description")
  end)
  ```
  """
  @spec embed(t(), Embed.t() | (Embed.t() -> Embed.t())) :: t()
  def embed(%__MODULE__{} = request, %Embed{} = embed) do
    update_payload(request, :embeds, request.payload.embeds ++ [embed])
  end

  def embed(%__MODULE__{} = request, fun) when is_function(fun) do
    update_payload(request, :embeds, request.payload.embeds ++ [fun.(Embed.new())])
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

  defdelegate embed_title(embed, title), to: Embed, as: :set_title
  defdelegate embed_description(embed, description), to: Embed, as: :set_description
  defdelegate embed_timestamp(embed, timestamp), to: Embed, as: :set_timestamp
  defdelegate embed_color(embed, color), to: Embed, as: :set_color
  defdelegate embed_footer(embed, text, icon_url), to: Embed, as: :set_footer

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
