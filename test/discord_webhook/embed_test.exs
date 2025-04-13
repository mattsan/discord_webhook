defmodule DiscordWebhook.EmbedTest do
  use ExUnit.Case

  alias DiscordWebhook.Embed

  doctest Embed

  setup do
    [embed: Embed.new()]
  end

  describe "new/0" do
    test "空の埋め込みを作成できる" do
      assert %Embed{
               title: nil,
               description: nil,
               timestamp: nil,
               color: nil,
               footer: nil
             } == Embed.new()
    end
  end

  describe "set_title/2" do
    test "title を設定できる", %{embed: embed} do
      assert %Embed{
               title: "something",
               description: nil,
               timestamp: nil,
               color: nil,
               footer: nil
             } == Embed.set_title(embed, "something")
    end

    test "文字列でないものは設定できない", %{embed: embed} do
      assert_raise(FunctionClauseError, fn ->
        Embed.set_title(embed, :something_wrong)
      end)
    end
  end

  describe "set_description/2" do
    test "description を設定できる", %{embed: embed} do
      assert %Embed{
               title: nil,
               description: "something",
               timestamp: nil,
               color: nil,
               footer: nil
             } == Embed.set_description(embed, "something")
    end

    test "文字列でないものは設定できない", %{embed: embed} do
      assert_raise(FunctionClauseError, fn ->
        Embed.set_description(embed, :something_wrong)
      end)
    end
  end

  describe "set_timestamp/2" do
    test "timestamp を文字列で設定できる", %{embed: embed} do
      assert %Embed{
               title: nil,
               description: nil,
               timestamp: "2025-04-12T12:34:56+09:00",
               color: nil
             } == Embed.set_timestamp(embed, "2025-04-12T12:34:56+09:00")
    end

    test "timestamp を Date で設定できる", %{embed: embed} do
      assert %Embed{
               title: nil,
               description: nil,
               timestamp: ~D[2025-04-12],
               color: nil,
               footer: nil
             } == Embed.set_timestamp(embed, ~D[2025-04-12])
    end

    test "timestamp を DateTime で設定できる", %{embed: embed} do
      assert %Embed{
               title: nil,
               description: nil,
               timestamp: ~U[2025-04-12T12:34:56+00:00],
               color: nil,
               footer: nil
             } == Embed.set_timestamp(embed, ~U[2025-04-12T12:34:56+00:00])
    end

    test "timestamp を NaiveDateTime で設定できる", %{embed: embed} do
      assert %Embed{
               title: nil,
               description: nil,
               timestamp: ~N[2025-04-12T12:34:56],
               color: nil,
               footer: nil
             } == Embed.set_timestamp(embed, ~N[2025-04-12T12:34:56])
    end

    test "文字列、日付、日時でないものは設定できない", %{embed: embed} do
      assert_raise(FunctionClauseError, fn ->
        Embed.set_timestamp(embed, :"2025-04-12")
      end)
    end
  end

  describe "set_color/2" do
    test "color を設定できる", %{embed: embed} do
      assert %Embed{
               title: nil,
               description: nil,
               timestamp: nil,
               color: 16_777_215,
               footer: nil
             } == Embed.set_color(embed, 0xFFFFFF)
    end

    test "ゼロ未満は設定できない", %{embed: embed} do
      assert_raise(FunctionClauseError, fn ->
        Embed.set_color(embed, -1)
      end)
    end

    test "0xFFFFFF より大きな値は設定できない", %{embed: embed} do
      assert_raise(FunctionClauseError, fn ->
        Embed.set_color(embed, 0x1000000)
      end)
    end

    test "数値でないものは設定できない", %{embed: embed} do
      assert_raise(FunctionClauseError, fn ->
        Embed.set_color(embed, "#FFFFFF")
      end)
    end
  end

  describe "set_footer/2" do
    test "footer を設定できる", %{embed: embed} do
      assert %Embed{
               title: nil,
               description: nil,
               timestamp: nil,
               color: nil,
               footer: %{text: "e.mattsan", icon_url: nil}
             } == Embed.set_footer(embed, "e.mattsan")
    end

    test "footer をアイコン指定付きで設定できる", %{embed: embed} do
      assert %Embed{
               title: nil,
               description: nil,
               timestamp: nil,
               color: nil,
               footer: %{text: "e.mattsan", icon_url: "https://example.com/icon.png"}
             } == Embed.set_footer(embed, "e.mattsan", "https://example.com/icon.png")
    end

    test "文字列でないものは text に設定できない", %{embed: embed} do
      assert_raise(FunctionClauseError, fn ->
        Embed.set_footer(embed, :something_wrong)
      end)
    end

    test "文字列や nil でないものは icon_url に設定できない", %{embed: embed} do
      assert_raise(FunctionClauseError, fn ->
        Embed.set_footer(embed, "e.mattsan", :something_wrong)
      end)
    end
  end
end
