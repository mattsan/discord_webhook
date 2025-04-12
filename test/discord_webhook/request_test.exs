defmodule DiscordWebhook.RequestTest do
  use ExUnit.Case
  alias DiscordWebhook.Payload
  alias DiscordWebhook.Request

  doctest Request

  setup do
    [request: Request.new()]
  end

  describe "set_content/2" do
    test "content を設定できる", %{request: request} do
      assert %Request{payload: %Payload{content: nil}, files: []} == request

      assert %Request{payload: %Payload{content: "a content"}, files: []} ==
               Request.set_content(request, "a content")
    end

    test "文字列でないものは設定できない", %{request: request} do
      assert_raise(FunctionClauseError, fn ->
        Request.set_content(request, :something_wrong)
      end)
    end
  end

  describe "set_username/2" do
    test "username を設定できる", %{request: request} do
      assert %Request{payload: %Payload{username: nil}, files: []} == request

      assert %Request{payload: %Payload{username: "e.mattsan"}, files: []} ==
               Request.set_username(request, "e.mattsan")
    end

    test "文字列でないものは設定できない", %{request: request} do
      assert_raise(FunctionClauseError, fn ->
        Request.set_username(request, :something_wrong)
      end)
    end
  end

  describe "set_avatar_url/2" do
    test "avatar_url を設定できる", %{request: request} do
      assert %Request{payload: %Payload{avatar_url: nil}, files: []} == request

      assert %Request{
               payload: %Payload{avatar_url: "https://example.com/path/to/avatar.png"},
               files: []
             } ==
               Request.set_avatar_url(request, "https://example.com/path/to/avatar.png")
    end

    test "文字列でないものは設定できない", %{request: request} do
      assert_raise(FunctionClauseError, fn ->
        Request.set_avatar_url(request, :something_wrong)
      end)
    end
  end

  describe "attach_file/3" do
    test "ファイルを添付できる", %{request: request} do
      assert %Request{payload: %Payload{attachments: []}, files: []} == request

      request = Request.attach_file(request, "a first text", "text1.txt", "A first sentence.")

      assert %Request{
               payload: %Payload{
                 attachments: [
                   {"a first text", "text1.txt"}
                 ]
               },
               files: [
                 {"text1.txt", "A first sentence."}
               ]
             } == request

      request = Request.attach_file(request, "a second text", "text2.txt", "A second sentence.")

      assert %Request{
               payload: %Payload{
                 attachments: [
                   {"a first text", "text1.txt"},
                   {"a second text", "text2.txt"}
                 ]
               },
               files: [
                 {"text1.txt", "A first sentence."},
                 {"text2.txt", "A second sentence."}
               ]
             } == request
    end

    test "文字列でないものは description に設定できない", %{request: request} do
      assert_raise(FunctionClauseError, fn ->
        Request.attach_file(request, :something_wrong, "text.txt", "A sentence.")
      end)
    end

    test "文字列でないものは filename に設定できない", %{request: request} do
      assert_raise(FunctionClauseError, fn ->
        Request.attach_file(request, "a text", :something_wrong, "A sentence.")
      end)
    end

    test "バイナリでないものはファイル本体として設定できない", %{request: request} do
      assert_raise(FunctionClauseError, fn ->
        Request.attach_file(request, "a text", "text.txt", :something_wrong)
      end)
    end
  end

  describe "to_form_multipart/1" do
    test "空のリクエストを変換できる", %{request: request} do
      assert [
               {"payload_json",
                ~S({"content":null,"username":null,"avatar_url":null,"attachments":[],"embeds":[]})}
             ] == Request.to_form_multipart(request)
    end

    test "埋め込み以外が設定されたリクエストを変換できる", %{request: request} do
      assert [
               {
                 "payload_json",
                 ~S({"content":"a content","username":"e.mattasn","avatar_url":"https://example.com/path/to/avatar.png","attachments":[{"id":0,"filename":"text1.txt","description":"a first text"},{"id":1,"filename":"text2.txt","description":"a second text"}],"embeds":[]})
               },
               {
                 "files[0]",
                 {
                   "A first sentence.",
                   [filename: "text1.txt", content_type: "text/plain"]
                 }
               },
               {
                 "files[1]",
                 {
                   "A second sentence.",
                   [filename: "text2.txt", content_type: "text/plain"]
                 }
               }
             ] ==
               request
               |> Request.set_content("a content")
               |> Request.set_username("e.mattasn")
               |> Request.set_avatar_url("https://example.com/path/to/avatar.png")
               |> Request.attach_file("a first text", "text1.txt", "A first sentence.")
               |> Request.attach_file("a second text", "text2.txt", "A second sentence.")
               |> Request.to_form_multipart()
    end
  end
end
