defmodule Framelens.CreatorsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Framelens.Creators` context.
  """

  @doc """
  Generate a creator.
  """
  def creator_fixture(attrs \\ %{}) do
    {:ok, creator} =
      attrs
      |> Enum.into(%{
        bio: "some bio",
        name: "some name"
      })
      |> Framelens.Creators.create_creator()

    creator
  end

  @doc """
  Generate a creator_platform.
  """
  def creator_platform_fixture(attrs \\ %{}) do
    {:ok, creator_platform} =
      attrs
      |> Enum.into(%{
        platform: "some platform",
        platform_id: "some platform_id"
      })
      |> Framelens.Creators.create_creator_platform()

    creator_platform
  end
end
