defmodule DiscordWebhook.Poll do
  @moduledoc """
  A struct of Poll Object in requst parameters.

  see https://discord.com/developers/docs/resources/poll#poll-create-request-object
  """

  @derive JSON.Encoder
  defstruct [:question, :answers, :expiry, :allow_multiselect, :layout_type]

  @default 1

  @type expiry() :: binary() | Date.t() | DateTime.t() | NaiveDateTime.t()
  @type t() :: %__MODULE__{
          question: binary(),
          answers: [],
          expiry: expiry(),
          allow_multiselect: boolean(),
          layout_type: integer()
        }

  defguardp is_expiry(term)
            when is_binary(term) or
                   is_struct(term, Date) or
                   is_struct(term, DateTime) or
                   is_struct(term, NaiveDateTime)

  @doc """
  Creates a new poll object.
  """
  @spec new :: t()
  def new do
    %__MODULE__{
      answers: [],
      allow_multiselect: false,
      layout_type: @default
    }
  end

  @doc """
  Sets question to the poll object.

  ### Examples

  ```elixir
  Poll.new()
  |> Poll.set_expiry("Which do you like?")
  ```
  """
  def set_question(%__MODULE__{} = poll, question) when is_binary(question) do
    %{poll | question: %{text: question}}
  end

  @doc """
  Adds answer to the poll object.

  ### Examples

  ```elixir
  Poll.new()
  |> Poll.add_answer("foo")
  |> Poll.add_answer("bar")
  |> Poll.add_answer("baz")
  ```
  """
  def add_answer(%__MODULE__{} = poll, answer) when is_binary(answer) do
    answers = poll.answers ++ [%{answer_id: length(poll.answers), poll_media: %{text: answer}}]
    %{poll | answers: answers}
  end

  @doc """
  Sets expiry to the poll object.

  ### Examples

  ```elixir
  Poll.new()
  |> Poll.set_expiry(~U[2025-04-12T12:34:56Z])
  ```
  """
  def set_expiry(%__MODULE__{} = poll, expiry) when is_expiry(expiry) do
    %{poll | expiry: expiry}
  end

  @doc """
  Allows to select multiple answers.

  ### Examples

  ```elixir
  Poll.new()
  |> Poll.allow_multiselect()
  ```
  """
  def allow_multiselect(%__MODULE__{} = poll) do
    %{poll | allow_multiselect: true}
  end
end
