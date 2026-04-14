defmodule Framelens.SubscriptionsTest do
  use Framelens.DataCase

  alias Framelens.Subscriptions

  describe "subscription" do
    alias Framelens.Subscriptions.Subscription

    import Framelens.SubscriptionsFixtures

    @invalid_attrs %{}

    test "list_subscription/0 returns all subscription" do
      subscription = subscription_fixture()
      assert Subscriptions.list_subscription() == [subscription]
    end

    test "get_subscription!/1 returns the subscription with given id" do
      subscription = subscription_fixture()
      assert Subscriptions.get_subscription!(subscription.id) == subscription
    end

    test "create_subscription/1 with valid data creates a subscription" do
      valid_attrs = %{}

      assert {:ok, %Subscription{} = subscription} = Subscriptions.create_subscription(valid_attrs)
    end

    test "create_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subscriptions.create_subscription(@invalid_attrs)
    end

    test "update_subscription/2 with valid data updates the subscription" do
      subscription = subscription_fixture()
      update_attrs = %{}

      assert {:ok, %Subscription{} = subscription} = Subscriptions.update_subscription(subscription, update_attrs)
    end

    test "update_subscription/2 with invalid data returns error changeset" do
      subscription = subscription_fixture()
      assert {:error, %Ecto.Changeset{}} = Subscriptions.update_subscription(subscription, @invalid_attrs)
      assert subscription == Subscriptions.get_subscription!(subscription.id)
    end

    test "delete_subscription/1 deletes the subscription" do
      subscription = subscription_fixture()
      assert {:ok, %Subscription{}} = Subscriptions.delete_subscription(subscription)
      assert_raise Ecto.NoResultsError, fn -> Subscriptions.get_subscription!(subscription.id) end
    end

    test "change_subscription/1 returns a subscription changeset" do
      subscription = subscription_fixture()
      assert %Ecto.Changeset{} = Subscriptions.change_subscription(subscription)
    end
  end

  describe "follows" do
    alias Framelens.Subscriptions.Follow

    import Framelens.SubscriptionsFixtures

    @invalid_attrs %{}

    test "list_follows/0 returns all follows" do
      follow = follow_fixture()
      assert Subscriptions.list_follows() == [follow]
    end

    test "get_follow!/1 returns the follow with given id" do
      follow = follow_fixture()
      assert Subscriptions.get_follow!(follow.id) == follow
    end

    test "create_follow/1 with valid data creates a follow" do
      valid_attrs = %{}

      assert {:ok, %Follow{} = follow} = Subscriptions.create_follow(valid_attrs)
    end

    test "create_follow/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subscriptions.create_follow(@invalid_attrs)
    end

    test "update_follow/2 with valid data updates the follow" do
      follow = follow_fixture()
      update_attrs = %{}

      assert {:ok, %Follow{} = follow} = Subscriptions.update_follow(follow, update_attrs)
    end

    test "update_follow/2 with invalid data returns error changeset" do
      follow = follow_fixture()
      assert {:error, %Ecto.Changeset{}} = Subscriptions.update_follow(follow, @invalid_attrs)
      assert follow == Subscriptions.get_follow!(follow.id)
    end

    test "delete_follow/1 deletes the follow" do
      follow = follow_fixture()
      assert {:ok, %Follow{}} = Subscriptions.delete_follow(follow)
      assert_raise Ecto.NoResultsError, fn -> Subscriptions.get_follow!(follow.id) end
    end

    test "change_follow/1 returns a follow changeset" do
      follow = follow_fixture()
      assert %Ecto.Changeset{} = Subscriptions.change_follow(follow)
    end
  end
end
