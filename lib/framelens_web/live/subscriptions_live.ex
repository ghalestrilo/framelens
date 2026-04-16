defmodule FramelensWeb.SubscriptionsLive do
  use FramelensWeb, :live_view

  alias Framelens.{Creators, Subscriptions}
  alias Ecto.Changeset

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id

    socket =
      socket
      |> assign(:user_id, user_id)
      |> assign(:followed, Subscriptions.followed_creators_for_user(user_id))
      |> assign(:search, "")
      |> assign(:results, [])
      |> assign(:new_form, new_creator_form())

    {:ok, socket}
  end

  def handle_event("search", %{"query" => query}, socket) do
    results = if String.trim(query) == "", do: [], else: Creators.search_creators(query)
    new_form = if results == [] and String.trim(query) != "" do
      validate_new_creator(%{"name" => query, "youtube_id" => ""})
    else
      new_creator_form()
    end
    {:noreply, assign(socket, search: query, results: results, new_form: new_form)}
  end

  def handle_event("follow", %{"id" => creator_id}, socket) do
    Subscriptions.follow_creator(socket.assigns.user_id, String.to_integer(creator_id))
    followed = Subscriptions.followed_creators_for_user(socket.assigns.user_id)
    {:noreply, assign(socket, followed: followed)}
  end

  def handle_event("unfollow", %{"id" => creator_id}, socket) do
    Subscriptions.unfollow_creator(socket.assigns.user_id, String.to_integer(creator_id))
    followed = Subscriptions.followed_creators_for_user(socket.assigns.user_id)
    {:noreply, assign(socket, followed: followed)}
  end

  def handle_event("validate_new", %{"creator" => params}, socket) do
    {:noreply, assign(socket, :new_form, validate_new_creator(params))}
  end

  def handle_event("add_new", %{"creator" => params}, socket) do
    changeset = validate_new_creator(params)

    if changeset.valid? do
      %{name: name, youtube_id: youtube_id} = Changeset.apply_changes(changeset)

      case Subscriptions.subscribe_new_creator(socket.assigns.user_id, name, youtube_id) do
        {:ok, _} ->
          followed = Subscriptions.followed_creators_for_user(socket.assigns.user_id)

          {:noreply,
           socket
           |> assign(:followed, followed)
           |> assign(:new_form, new_creator_form())
           |> put_flash(:info, "#{name} added and followed.")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Something went wrong. Please try again.")}
      end
    else
      {:noreply, assign(socket, :new_form, Map.put(changeset, :action, :validate))}
    end
  end

  defp new_creator_form do
    {%{}, %{name: :string, youtube_id: :string}}
    |> Changeset.cast(%{}, [:name, :youtube_id])
    |> to_form(as: "creator")
  end

  defp validate_new_creator(params) do
    {%{}, %{name: :string, youtube_id: :string}}
    |> Changeset.cast(params, [:name, :youtube_id])
    |> Changeset.validate_required([:name, :youtube_id])
    |> Changeset.validate_format(:youtube_id, ~r/^UC[a-zA-Z0-9_-]{22}$/,
      message: "must be a valid YouTube channel ID (starts with UC)"
    )
    |> to_form(as: "creator")
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Subscriptions
        <:subtitle>Manage the creators you follow</:subtitle>
      </.header>

      <div class="mt-6 space-y-2">
        <h2 class="font-semibold text-sm text-base-content/60 uppercase tracking-wide">
          Following ({length(@followed)})
        </h2>
        <div :if={@followed == []} class="text-base-content/50 text-sm">
          You're not following anyone yet.
        </div>
        <ul class="divide-y divide-base-200">
          <li :for={creator <- @followed} class="flex items-center justify-between py-3">
            <span class="font-medium">{creator.name}</span>
            <button
              phx-click="unfollow"
              phx-value-id={creator.id}
              class="btn btn-sm btn-ghost text-error"
            >
              Unfollow
            </button>
          </li>
        </ul>
      </div>

      <div class="divider" />

      <div class="space-y-3">
        <h2 class="font-semibold text-sm text-base-content/60 uppercase tracking-wide">
          Find creators
        </h2>
        <form phx-change="search">
          <input
            type="text"
            name="query"
            value={@search}
            placeholder="Search by name..."
            phx-debounce="300"
            class="input input-bordered w-full"
            autocomplete="off"
          />
        </form>
        <ul :if={@results != []} class="divide-y divide-base-200 rounded-lg border border-base-300">
          <li :for={creator <- @results} class="flex items-center justify-between px-4 py-3">
            <span>{creator.name}</span>
            <%= if Enum.any?(@followed, & &1.id == creator.id) do %>
              <span class="text-sm text-base-content/40">Following</span>
            <% else %>
              <button
                phx-click="follow"
                phx-value-id={creator.id}
                class="btn btn-sm btn-primary"
              >
                Follow
              </button>
            <% end %>
          </li>
        </ul>

        <div :if={@results == [] and String.trim(@search) != ""} class="space-y-3">
          <p class="text-sm text-base-content/60">
            No creators found for <strong>{@search}</strong>. Add them manually:
          </p>
          <.form
            for={@new_form}
            phx-change="validate_new"
            phx-submit="add_new"
            class="space-y-3"
          >
            <.input field={@new_form[:name]} label="Name" placeholder="e.g. Fireship" />
            <.input
              field={@new_form[:youtube_id]}
              label="YouTube Channel ID"
              placeholder="e.g. UCsBjURrPoezykLs9EqgamOA"
            />
            <.button variant="primary" phx-disable-with="Adding...">Add & Follow</.button>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
