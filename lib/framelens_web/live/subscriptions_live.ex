defmodule FramelensWeb.SubscriptionsLive do
  use FramelensWeb, :live_view

  alias Framelens.{Creators, PlatformStats, Subscriptions}
  alias Framelens.Platform.Registry
  alias Ecto.Changeset

  @platforms Registry.all()

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id

    socket =
      socket
      |> assign(:user_id, user_id)
      |> assign_followed()
      |> assign(:most_followed, PlatformStats.most_followed())
      |> assign(:search, "")
      |> assign(:results, [])
      |> assign(:platform_ids, %{})
      |> assign(:new_form, new_creator_form())

    {:ok, socket}
  end

  def handle_event("search", %{"query" => query}, socket) do
    results = if String.trim(query) == "", do: [], else: Creators.search_creators(query)

    {new_form, platform_ids} =
      if results == [] and String.trim(query) != "" do
        {validate_new_creator(%{"name" => query}), socket.assigns.platform_ids}
      else
        {new_creator_form(), %{}}
      end

    {:noreply,
     assign(socket,
       search: query,
       results: results,
       new_form: new_form,
       platform_ids: platform_ids
     )}
  end

  def handle_event("follow", %{"id" => creator_id}, socket) do
    {:noreply, do_follow(socket, String.to_integer(creator_id))}
  end

  def handle_event("unfollow", %{"id" => creator_id}, socket) do
    {:noreply, do_unfollow(socket, String.to_integer(creator_id))}
  end

  def handle_info({:subs_follow, creator_id}, socket) do
    {:noreply, do_follow(socket, creator_id)}
  end

  def handle_info({:subs_unfollow, creator_id}, socket) do
    {:noreply, do_unfollow(socket, creator_id)}
  end

  def handle_event("validate_new", %{"creator" => params}, socket) do
    platform_ids = Map.get(params, "platform_ids", %{})

    {:noreply,
     socket
     |> assign(:platform_ids, platform_ids)
     |> assign(:new_form, validate_new_creator(params))}
  end

  def handle_event("add_new", %{"creator" => params}, socket) do
    changeset = build_changeset(params)

    if changeset.valid? do
      %{name: name, platforms: platforms} = Changeset.apply_changes(changeset)

      case Subscriptions.subscribe_new_creator(socket.assigns.user_id, name, platforms) do
        {:ok, _} ->
          followed = Subscriptions.followed_creators_for_user(socket.assigns.user_id)

          {:noreply,
           socket
           |> assign(:followed, followed)
           |> assign(:platform_ids, %{})
           |> assign(:new_form, new_creator_form())
           |> put_flash(:info, "#{name} added and followed.")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Something went wrong. Please try again.")}
      end
    else
      {:noreply,
       assign(
         socket,
         :new_form,
         changeset |> Map.put(:action, :validate) |> to_form(as: "creator")
       )}
    end
  end

  defp new_creator_form do
    build_changeset(%{}) |> to_form(as: "creator")
  end

  defp validate_new_creator(params) do
    build_changeset(params) |> to_form(as: "creator")
  end

  defp build_changeset(params) do
    platform_ids = Map.get(params, "platform_ids", %{})

    filled_platforms =
      Enum.flat_map(@platforms, fn {key, _} ->
        case Map.get(platform_ids, key, "") do
          "" -> []
          id -> [%{platform: key, platform_id: String.trim(id)}]
        end
      end)

    {%{name: nil, platforms: []}, %{name: :string, platforms: {:array, :map}}}
    |> Changeset.cast(Map.put(params, "platforms", filled_platforms), [:name, :platforms])
    |> Changeset.validate_required([:name])
    |> validate_at_least_one_platform()
  end

  defp do_follow(socket, creator_id) do
    Subscriptions.follow_creator(socket.assigns.user_id, creator_id)
    Task.start(fn -> PlatformStats.refresh() end)
    assign_followed(socket)
  end

  defp do_unfollow(socket, creator_id) do
    Subscriptions.unfollow_creator(socket.assigns.user_id, creator_id)
    Task.start(fn -> PlatformStats.refresh() end)
    assign_followed(socket)
  end

  defp assign_followed(socket) do
    followed = Subscriptions.followed_creators_for_user(socket.assigns.user_id)
    assign(socket, followed: followed, followed_ids: MapSet.new(followed, & &1.id))
  end

  defp validate_at_least_one_platform(changeset) do
    case Changeset.get_field(changeset, :platforms) do
      [] -> Changeset.add_error(changeset, :platforms, "at least one platform ID is required")
      _ -> changeset
    end
  end

  def render(assigns) do
    assigns = assign(assigns, :platforms, @platforms)

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

            <fieldset class="space-y-2">
              <legend class="text-sm font-medium">
                Platforms <span class="text-base-content/50 font-normal">(fill in at least one)</span>
              </legend>
              <div :for={{key, meta} <- @platforms} class="flex items-center gap-2">
                <label class="w-24 text-sm text-base-content/70 shrink-0">{meta.label}</label>
                <input
                  type="text"
                  name={"creator[platform_ids][#{key}]"}
                  value={Map.get(@platform_ids, key, "")}
                  placeholder={meta.placeholder}
                  class="input input-bordered input-sm flex-1"
                  phx-debounce="300"
                />
              </div>
              <p :if={@new_form[:platforms].errors != []} class="text-sm text-error mt-1">
                {translate_error(hd(@new_form[:platforms].errors))}
              </p>
            </fieldset>

            <.button variant="primary" phx-disable-with="Adding...">Add & Follow</.button>
          </.form>
        </div>
      </div>

      <div :if={@most_followed != []} class="divider" />

      <div :if={@most_followed != []} class="space-y-3">
        <h2 class="font-semibold text-sm text-base-content/60 uppercase tracking-wide">
          Popular channels
        </h2>
        <.live_component
          module={FramelensWeb.CreatorListComponent}
          id="subs-suggestions"
          creators={@most_followed}
          followed_ids={@followed_ids}
          on_follow={:subs_follow}
          on_unfollow={:subs_unfollow}
        />
      </div>
    </Layouts.app>
    """
  end
end
