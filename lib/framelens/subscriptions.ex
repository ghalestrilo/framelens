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

  alias Framelens.Subscriptions.Follow
  alias Framelens.Creators.{Creator, CreatorPlatform}

  def followed_creators_for_user(user_id) do
    Repo.all(
      from f in Follow,
        join: c in Creator, on: c.id == f.creator_id,
        where: f.user_id == ^user_id,
        select: %{id: c.id, name: c.name, follow_id: f.id}
    )
  end

  def subscribe_new_creator(user_id, name, youtube_id) do
    case Repo.get_by(CreatorPlatform, platform: "youtube", platform_id: youtube_id) do
      %CreatorPlatform{creator_id: creator_id} ->
        follow_creator(user_id, creator_id)

      nil ->
        Repo.transaction(fn ->
          creator = Repo.insert!(%Framelens.Creators.Creator{name: name})

          Repo.insert!(%CreatorPlatform{
            creator_id: creator.id,
            platform: "youtube",
            platform_id: youtube_id
          })

          {:ok, follow} = follow_creator(user_id, creator.id)
          follow
        end)
    end
  end

  def follow_creator(user_id, creator_id) do
    %Follow{}
    |> Follow.changeset(%{user_id: user_id, creator_id: creator_id})
    |> Repo.insert(on_conflict: :nothing, conflict_target: [:user_id, :creator_id])
  end

  def unfollow_creator(user_id, creator_id) do
    case Repo.get_by(Follow, user_id: user_id, creator_id: creator_id) do
      nil -> {:ok, nil}
      follow -> Repo.delete(follow)
    end
  end

  @platform_modules %{
    "youtube" => Framelens.Platform.YouTube
  }

  def platforms_for_user(user_id) do
    Repo.all(
      from f in Follow,
        join: c in Creator, on: c.id == f.creator_id,
        join: p in CreatorPlatform, on: p.creator_id == c.id,
        where: f.user_id == ^user_id,
        select: %{platform: p.platform, platform_id: p.platform_id, name: c.name}
    )
    |> build_platform_structs()
  end

  def all_followed_creator_platforms do
    Repo.all(
      from p in CreatorPlatform,
        join: c in Creator, on: c.id == p.creator_id,
        join: f in Follow, on: f.creator_id == c.id,
        distinct: p.id,
        select: %{platform: p.platform, platform_id: p.platform_id, name: c.name}
    )
    |> build_platform_structs()
  end

  defp build_platform_structs(rows) do
    Enum.flat_map(rows, fn %{platform: key, platform_id: id, name: name} ->
      case Map.fetch(@platform_modules, key) do
        {:ok, mod} -> [struct(mod, platform_id: id, name: name)]
        :error -> []
      end
    end)
  end

  @doc """
  Returns the list of follows.

  ## Examples

      iex> list_follows()
      [%Follow{}, ...]

  """
  def list_follows do
    Repo.all(Follow)
  end

  @doc """
  Gets a single follow.

  Raises `Ecto.NoResultsError` if the Follow does not exist.

  ## Examples

      iex> get_follow!(123)
      %Follow{}

      iex> get_follow!(456)
      ** (Ecto.NoResultsError)

  """
  def get_follow!(id), do: Repo.get!(Follow, id)

  @doc """
  Creates a follow.

  ## Examples

      iex> create_follow(%{field: value})
      {:ok, %Follow{}}

      iex> create_follow(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_follow(attrs) do
    %Follow{}
    |> Follow.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a follow.

  ## Examples

      iex> update_follow(follow, %{field: new_value})
      {:ok, %Follow{}}

      iex> update_follow(follow, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_follow(%Follow{} = follow, attrs) do
    follow
    |> Follow.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a follow.

  ## Examples

      iex> delete_follow(follow)
      {:ok, %Follow{}}

      iex> delete_follow(follow)
      {:error, %Ecto.Changeset{}}

  """
  def delete_follow(%Follow{} = follow) do
    Repo.delete(follow)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking follow changes.

  ## Examples

      iex> change_follow(follow)
      %Ecto.Changeset{data: %Follow{}}

  """
  def change_follow(%Follow{} = follow, attrs \\ %{}) do
    Follow.changeset(follow, attrs)
  end
end
