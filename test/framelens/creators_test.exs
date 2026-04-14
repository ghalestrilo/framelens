defmodule Framelens.CreatorsTest do
  use Framelens.DataCase

  alias Framelens.Creators

  describe "creators" do
    alias Framelens.Creators.Creator

    import Framelens.CreatorsFixtures

    @invalid_attrs %{name: nil, bio: nil}

    test "list_creators/0 returns all creators" do
      creator = creator_fixture()
      assert Creators.list_creators() == [creator]
    end

    test "get_creator!/1 returns the creator with given id" do
      creator = creator_fixture()
      assert Creators.get_creator!(creator.id) == creator
    end

    test "create_creator/1 with valid data creates a creator" do
      valid_attrs = %{name: "some name", bio: "some bio"}

      assert {:ok, %Creator{} = creator} = Creators.create_creator(valid_attrs)
      assert creator.name == "some name"
      assert creator.bio == "some bio"
    end

    test "create_creator/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Creators.create_creator(@invalid_attrs)
    end

    test "update_creator/2 with valid data updates the creator" do
      creator = creator_fixture()
      update_attrs = %{name: "some updated name", bio: "some updated bio"}

      assert {:ok, %Creator{} = creator} = Creators.update_creator(creator, update_attrs)
      assert creator.name == "some updated name"
      assert creator.bio == "some updated bio"
    end

    test "update_creator/2 with invalid data returns error changeset" do
      creator = creator_fixture()
      assert {:error, %Ecto.Changeset{}} = Creators.update_creator(creator, @invalid_attrs)
      assert creator == Creators.get_creator!(creator.id)
    end

    test "delete_creator/1 deletes the creator" do
      creator = creator_fixture()
      assert {:ok, %Creator{}} = Creators.delete_creator(creator)
      assert_raise Ecto.NoResultsError, fn -> Creators.get_creator!(creator.id) end
    end

    test "change_creator/1 returns a creator changeset" do
      creator = creator_fixture()
      assert %Ecto.Changeset{} = Creators.change_creator(creator)
    end
  end

  describe "creator_platforms" do
    alias Framelens.Creators.CreatorPlatform

    import Framelens.CreatorsFixtures

    @invalid_attrs %{platform: nil, platform_id: nil}

    test "list_creator_platforms/0 returns all creator_platforms" do
      creator_platform = creator_platform_fixture()
      assert Creators.list_creator_platforms() == [creator_platform]
    end

    test "get_creator_platform!/1 returns the creator_platform with given id" do
      creator_platform = creator_platform_fixture()
      assert Creators.get_creator_platform!(creator_platform.id) == creator_platform
    end

    test "create_creator_platform/1 with valid data creates a creator_platform" do
      valid_attrs = %{platform: "some platform", platform_id: "some platform_id"}

      assert {:ok, %CreatorPlatform{} = creator_platform} = Creators.create_creator_platform(valid_attrs)
      assert creator_platform.platform == "some platform"
      assert creator_platform.platform_id == "some platform_id"
    end

    test "create_creator_platform/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Creators.create_creator_platform(@invalid_attrs)
    end

    test "update_creator_platform/2 with valid data updates the creator_platform" do
      creator_platform = creator_platform_fixture()
      update_attrs = %{platform: "some updated platform", platform_id: "some updated platform_id"}

      assert {:ok, %CreatorPlatform{} = creator_platform} = Creators.update_creator_platform(creator_platform, update_attrs)
      assert creator_platform.platform == "some updated platform"
      assert creator_platform.platform_id == "some updated platform_id"
    end

    test "update_creator_platform/2 with invalid data returns error changeset" do
      creator_platform = creator_platform_fixture()
      assert {:error, %Ecto.Changeset{}} = Creators.update_creator_platform(creator_platform, @invalid_attrs)
      assert creator_platform == Creators.get_creator_platform!(creator_platform.id)
    end

    test "delete_creator_platform/1 deletes the creator_platform" do
      creator_platform = creator_platform_fixture()
      assert {:ok, %CreatorPlatform{}} = Creators.delete_creator_platform(creator_platform)
      assert_raise Ecto.NoResultsError, fn -> Creators.get_creator_platform!(creator_platform.id) end
    end

    test "change_creator_platform/1 returns a creator_platform changeset" do
      creator_platform = creator_platform_fixture()
      assert %Ecto.Changeset{} = Creators.change_creator_platform(creator_platform)
    end
  end
end
