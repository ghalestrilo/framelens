defmodule Framelens.QueueCacheTest do
  use ExUnit.Case, async: false

  alias Framelens.QueueCache

  @email "user@example.com"
  @other_email "other@example.com"
  @post %{url: "https://youtu.be/abc123", title: "Test Video", author: "Tester"}
  @post2 %{url: "https://youtu.be/def456", title: "Second Video", author: "Tester"}

  setup do
    on_exit(fn ->
      QueueCache.clear(@email)
      QueueCache.clear(@other_email)
    end)

    :ok
  end

  test "get/1 returns [] for unknown email" do
    assert QueueCache.get(@email) == []
  end

  test "add/2 then get/1 returns list with the post" do
    QueueCache.add(@email, @post)
    assert QueueCache.get(@email) == [@post]
  end

  test "multiple add/2 calls accumulate in FIFO order" do
    QueueCache.add(@email, @post)
    QueueCache.add(@email, @post2)
    assert QueueCache.get(@email) == [@post, @post2]
  end

  test "add/2 with duplicate url is idempotent" do
    QueueCache.add(@email, @post)
    QueueCache.add(@email, @post)
    assert QueueCache.get(@email) == [@post]
  end

  test "remove/2 removes post by url" do
    QueueCache.add(@email, @post)
    QueueCache.add(@email, @post2)
    QueueCache.remove(@email, @post.url)
    assert QueueCache.get(@email) == [@post2]
  end

  test "remove/2 with unknown url is a no-op" do
    QueueCache.add(@email, @post)
    QueueCache.remove(@email, "https://unknown.com/video")
    assert QueueCache.get(@email) == [@post]
  end

  test "clear/1 resets to []" do
    QueueCache.add(@email, @post)
    QueueCache.clear(@email)
    assert QueueCache.get(@email) == []
  end

  test "clear/1 does not affect other emails" do
    QueueCache.add(@email, @post)
    QueueCache.add(@other_email, @post2)
    QueueCache.clear(@email)
    assert QueueCache.get(@other_email) == [@post2]
  end

  test "two emails have independent state" do
    QueueCache.add(@email, @post)
    assert QueueCache.get(@other_email) == []
  end
end
