defmodule FramelensWeb.Admin.ObanJobLive do
  import Ecto.Query, only: [dynamic: 2]

  use Backpex.LiveResource,
    per_page_default: 100,
    adapter_config: [
      schema: Oban.Job,
      repo: Framelens.Repo,
      update_changeset: &__MODULE__.changeset/3,
      create_changeset: &__MODULE__.changeset/3
    ]

  @impl Backpex.LiveResource
  def layout(_assigns), do: {FramelensWeb.Layouts, :admin}

  @impl Backpex.LiveResource
  def singular_name, do: "Job"

  @impl Backpex.LiveResource
  def plural_name, do: "Jobs"

  @impl Backpex.LiveResource
  def fields do
    [
      queue: %{
        module: Backpex.Fields.Text,
        label: "Queue"
      },
      worker: %{
        module: Backpex.Fields.Text,
        label: "Worker",
        except: [:new, :edit],
        render: fn assigns ->
          ~H"""
          <span>{@item.worker |> String.split(".") |> List.last()}</span>
          """
        end,
      },
      state: %{
        module: Backpex.Fields.Text,
        label: "State",
        render: fn assigns ->
          ~H"""
          <span class={"px-3 rounded-2xl #{get_state_class(@item)}"}>{@item.state}</span>
          """
        end,
        except: [:new, :edit]
      },
      args: %{
        module: Backpex.Fields.Text,
        label: "Args",
        render: fn assigns ->
          ~H"""
          <pre class={" #{get_state_class(@item)}"}>{inspect(@item.args)}</pre>
          """
        end,
      },
      attempt: %{
        module: Backpex.Fields.Number,
        label: "Attempt",
        except: [:new, :edit]
      },
      max_attempts: %{
        module: Backpex.Fields.Number,
        label: "Max Attempts"
      },
      priority: %{
        module: Backpex.Fields.Number,
        label: "Priority"
      },
      inserted_at: %{
        module: Backpex.Fields.DateTime,
        label: "Inserted At",
        except: [:new, :edit]
      },
      scheduled_at: %{
        module: Backpex.Fields.DateTime,
        label: "Scheduled At",
        except: [:new, :edit]
      }
    ]
  end

  @impl Backpex.LiveResource
  def item_actions(default_actions) do
    default_actions
    |> Enum.filter(fn {name, action } -> name != :edit end)
    |> Enum.concat([
      retry: %{module: FramelensWeb.Admin.ObanJobLive.RetryJob, only: [:row]}
    ])
  end

  @impl Backpex.LiveResource
  def metrics do
    [
      worker_states: %{
        module: FramelensWeb.Admin.ObanJobLive.WorkerStateMetric,
        label: "Jobs by Worker",
        class: "w-full",
        select: dynamic([j], count(j.id)),
        format: nil
      }
    ]
  end

  def filters do
    [
      state: %{
        module: FramelensWeb.Admin.ObanJobLive.MultiJobStateSelect,
        label: "State",
        opts: [placeholder: "Select state..."]
      },
      worker: %{
        module: FramelensWeb.Admin.ObanJobLive.WorkerFilter,
        label: "Worker",
        opts: [placeholder: "Select worker..."]
      }
    ]
  end

  def changeset(job, attrs, _metadata) do
    import Ecto.Changeset

    job
    |> cast(attrs, [:queue, :max_attempts, :priority])
    |> validate_required([:queue])
  end

  defmodule MultiJobStateSelect do
    use Backpex.Filters.MultiSelect

    @impl Backpex.Filter
    def can?(_), do: true

    @impl Backpex.Filter
    def label, do: "State"

    @impl Backpex.Filters.MultiSelect
    def prompt, do: "Select state ..."

    @impl Backpex.Filters.MultiSelect
    def options(_), do: Oban.Job.states() |> Enum.map(&{Atom.to_string(&1), Atom.to_string(&1)})
  end

  defmodule WorkerFilter do
    use Backpex.Filters.MultiSelect

    import Ecto.Query
    alias Framelens.Repo

    @impl Backpex.Filter
    def can?(_), do: true

    @impl Backpex.Filter
    def label, do: "Worker"

    @impl Backpex.Filters.MultiSelect
    def prompt, do: "Select worker ..."

    @impl Backpex.Filters.MultiSelect
    def options(_) do
      Repo.all(from j in Oban.Job, select: j.worker, distinct: true, order_by: j.worker)
      |> Enum.map(&{String.split(&1, ".") |> List.last(), &1})
    end
  end

  defp get_state_class(%{ state: state }) when state == "completed", do: "text-green-300 bg-green-900/50"
  defp get_state_class(%{ state: state }) when state in ["available",  "retryable",  "executing",  "scheduled"], do: "text-yellow-300 bg-yellow-900/50"
  defp get_state_class(%{ state: state }) when state in ["suspended", "cancelled", "discarded"], do: "text-red-300 bg-red-900/50"
  defp get_state_class(_), do: ""

  defmodule RetryJob do
    use BackpexWeb, :item_action

    @impl Backpex.ItemAction
    def icon(assigns, _item) do
      ~H"""
      <Backpex.HTML.CoreComponents.icon
        name="hero-arrow-path"
        class="h-5 w-5 cursor-pointer transition duration-75 hover:scale-110 hover:text-yellow-500"
      />
      """
    end

    @impl Backpex.ItemAction
    def label(_assigns, _item), do: "Retry"

    @impl Backpex.ItemAction
    def handle(socket, items, _params) do
      Enum.each(items, fn job -> Oban.retry_job(job.id) end)

      socket
      |> clear_flash()
      |> put_flash(:info, "#{length(items)} job(s) queued for retry.")
      |> ok()
    end
  end

  defmodule WorkerStateMetric do
    @behaviour Backpex.Metric

    import Ecto.Query
    use BackpexWeb, :html

    @states ~w(completed available executing scheduled retryable cancelled discarded)

    @impl Backpex.Metric
    def query(query, _select, repo) do
      repo.all(
        from j in query,
          group_by: [j.worker, j.state],
          select: {j.worker, j.state, count(j.id)}
      )
    end

    @impl Backpex.Metric
    def format(rows, _format) do
      rows
      |> Enum.group_by(fn {worker, _, _} -> worker end, fn {_, state, count} -> {state, count} end)
      |> Enum.map(fn {worker, state_counts} ->
        total = Enum.sum(Enum.map(state_counts, fn {_, n} -> n end))
        by_state = Map.new(state_counts)
        {worker, total, by_state}
      end)
      |> Enum.sort_by(fn {_, total, _} -> total end, :desc)
    end

    @impl Backpex.Metric
    def render(assigns) do
      %{metric: metric} = assigns
      rows = metric.module.format(metric.data, metric.format)
      assigns = assign(assigns, rows: rows, states: @states)

      ~H"""
      <div class={["card bg-base-100 mb-4 shadow-sm w-full", @metric[:class]]}>
        <div class="card-body p-4">
          <p class="card-title text-base-content/60 text-sm font-normal mb-2">{@metric.label}</p>
          <div :if={@rows == []} class="text-base-content/40 text-sm">No jobs found.</div>
          <table :if={@rows != []} class="table table-xs w-full">
            <thead>
              <tr>
                <th>Worker</th>
                <th class="text-right">Total</th>
                <th :for={state <- @states} class="text-right">{state}</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={{worker, total, by_state} <- @rows}>
                <td class="font-mono text-xs">
                  <a href={filter_url(worker, nil)} class="hover:underline">
                    {worker |> String.split(".") |> List.last()}
                  </a>
                </td>
                <td class="text-right font-semibold">{total}</td>
                <td :for={state <- @states} class="text-right">
                  <% count = Map.get(by_state, state, 0) %>
                  <% pct = if total > 0, do: Float.round(count / total * 100, 1), else: 0.0 %>
                  <a
                    :if={count > 0}
                    href={filter_url(worker, state)}
                    class={"text-xs px-1 rounded #{state_class(state)} hover:opacity-80 flex items-baseline justify-between w-fit min-w-22 ml-auto"}
                  >
                    <span>{count}</span> <span class="opacity-60">({pct}%)</span>
                  </a>
                  <span :if={count == 0} class="text-base-content/20">—</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      """
    end

    defp filter_url(worker, nil) do
      "/admin/jobs?" <> Plug.Conn.Query.encode(%{
        "filters" => %{"worker" => [worker]},
        "filters_changed" => "true"
      })
    end

    defp filter_url(worker, state) do
      "/admin/jobs?" <> Plug.Conn.Query.encode(%{
        "filters" => %{"worker" => [worker], "state" => [state]},
        "filters_changed" => "true"
      })
    end

    defp states, do: @states

    defp state_class("completed"), do: "text-green-300 bg-green-900/50"
    defp state_class(s) when s in ~w(available retryable executing scheduled), do: "text-yellow-300 bg-yellow-900/50"
    defp state_class(s) when s in ~w(suspended cancelled discarded), do: "text-red-300 bg-red-900/50"
    defp state_class(_), do: ""
  end
end
