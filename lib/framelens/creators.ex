defmodule Framelens.Creators do
  @moduledoc """
  The Creators context.
  """

  import Ecto.Query, warn: false
  alias Framelens.Repo

  alias Framelens.Creators.Creator

  @doc """
  Inserts a creator with a single YouTube platform entry, skipping silently if
  that channel_id already exists. Returns :ok regardless.
  """
  def import_youtube_creator(name, channel_id) do
    alias Framelens.Creators.CreatorPlatform

    already_exists =
      Repo.exists?(
        from p in CreatorPlatform,
          where: p.platform == "youtube" and p.platform_id == ^channel_id
      )

    unless already_exists do
      %Creator{}
      |> Creator.changeset_with_platforms(%{
        name: name,
        platforms: [%{platform: "youtube", platform_id: channel_id}]
      })
      |> Repo.insert()
    end

    :ok
  end

  @doc """
  Returns the list of creators.

  ## Examples

      iex> list_creators()
      [%Creator{}, ...]

  """
  def list_creators do
    Repo.all(Creator)
  end

  def search_creators(query) do
    term = "%#{query}%"
    Repo.all(from c in Creator, where: ilike(c.name, ^term), order_by: c.name, limit: 10)
  end

  @doc """
  Gets a single creator.

  Raises `Ecto.NoResultsError` if the Creator does not exist.

  ## Examples

      iex> get_creator!(123)
      %Creator{}

      iex> get_creator!(456)
      ** (Ecto.NoResultsError)

  """
  def get_creator!(id), do: Repo.get!(Creator, id)

  @doc """
  Creates a creator.

  ## Examples

      iex> create_creator(%{field: value})
      {:ok, %Creator{}}

      iex> create_creator(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_creator(attrs) do
    %Creator{}
    |> Creator.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a creator.

  ## Examples

      iex> update_creator(creator, %{field: new_value})
      {:ok, %Creator{}}

      iex> update_creator(creator, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_creator(%Creator{} = creator, attrs) do
    creator
    |> Creator.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a creator.

  ## Examples

      iex> delete_creator(creator)
      {:ok, %Creator{}}

      iex> delete_creator(creator)
      {:error, %Ecto.Changeset{}}

  """
  def delete_creator(%Creator{} = creator) do
    Repo.delete(creator)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking creator changes.

  ## Examples

      iex> change_creator(creator)
      %Ecto.Changeset{data: %Creator{}}

  """
  def change_creator(%Creator{} = creator, attrs \\ %{}) do
    Creator.changeset(creator, attrs)
  end

  alias Framelens.Creators.CreatorPlatform

  @doc """
  Returns the list of creator_platforms.

  ## Examples

      iex> list_creator_platforms()
      [%CreatorPlatform{}, ...]

  """
  def list_creator_platforms do
    Repo.all(CreatorPlatform)
  end

  @doc """
  Gets a single creator_platform.

  Raises `Ecto.NoResultsError` if the Creator platform does not exist.

  ## Examples

      iex> get_creator_platform!(123)
      %CreatorPlatform{}

      iex> get_creator_platform!(456)
      ** (Ecto.NoResultsError)

  """
  def get_creator_platform!(id), do: Repo.get!(CreatorPlatform, id)

  @doc """
  Creates a creator_platform.

  ## Examples

      iex> create_creator_platform(%{field: value})
      {:ok, %CreatorPlatform{}}

      iex> create_creator_platform(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_creator_platform(attrs) do
    %CreatorPlatform{}
    |> CreatorPlatform.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a creator_platform.

  ## Examples

      iex> update_creator_platform(creator_platform, %{field: new_value})
      {:ok, %CreatorPlatform{}}

      iex> update_creator_platform(creator_platform, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_creator_platform(%CreatorPlatform{} = creator_platform, attrs) do
    creator_platform
    |> CreatorPlatform.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a creator_platform.

  ## Examples

      iex> delete_creator_platform(creator_platform)
      {:ok, %CreatorPlatform{}}

      iex> delete_creator_platform(creator_platform)
      {:error, %Ecto.Changeset{}}

  """
  def delete_creator_platform(%CreatorPlatform{} = creator_platform) do
    Repo.delete(creator_platform)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking creator_platform changes.

  ## Examples

      iex> change_creator_platform(creator_platform)
      %Ecto.Changeset{data: %CreatorPlatform{}}

  """
  def change_creator_platform(%CreatorPlatform{} = creator_platform, attrs \\ %{}) do
    CreatorPlatform.changeset(creator_platform, attrs)
  end
end
