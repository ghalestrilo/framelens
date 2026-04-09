defmodule Framelens.Subscriptions do
  @moduledoc """
  The Subscriptions context.
  """

  import Ecto.Query, warn: false
  alias Framelens.Repo

  alias Framelens.Subscriptions.Subscription

  @doc """
  Returns the list of subscription.

  ## Examples

      iex> list_subscription()
      [%Subscription{}, ...]

  """
  def list_subscription do
    raise "TODO"
  end

  @doc """
  Gets a single subscription.

  Raises if the Subscription does not exist.

  ## Examples

      iex> get_subscription!(123)
      %Subscription{}

  """
  def get_subscription!(id), do: raise "TODO"

  @doc """
  Creates a subscription.

  ## Examples

      iex> create_subscription(%{field: value})
      {:ok, %Subscription{}}

      iex> create_subscription(%{field: bad_value})
      {:error, ...}

  """
  def create_subscription(attrs) do
    raise "TODO"
  end

  @doc """
  Updates a subscription.

  ## Examples

      iex> update_subscription(subscription, %{field: new_value})
      {:ok, %Subscription{}}

      iex> update_subscription(subscription, %{field: bad_value})
      {:error, ...}

  """
  def update_subscription(%Subscription{} = subscription, attrs) do
    raise "TODO"
  end

  @doc """
  Deletes a Subscription.

  ## Examples

      iex> delete_subscription(subscription)
      {:ok, %Subscription{}}

      iex> delete_subscription(subscription)
      {:error, ...}

  """
  def delete_subscription(%Subscription{} = subscription) do
    raise "TODO"
  end

  @doc """
  Returns a data structure for tracking subscription changes.

  ## Examples

      iex> change_subscription(subscription)
      %Todo{...}

  """
  def change_subscription(%Subscription{} = subscription, _attrs \\ %{}) do
    raise "TODO"
  end

  def get_all_content(%{youtube_id: youtube_id}) do
    youtube_rss_url = "https://www.youtube.com/feeds/videos.xml?channel_id=#{youtube_id}"
    with {:ok, youtube_feed} <- ElixirRss.fetch_and_parse(youtube_rss_url) do
      %{title: title} = youtube_feed
      {:ok, Enum.map(youtube_feed.entries, &Map.put(&1, :author, title))}
    end
  end
end
