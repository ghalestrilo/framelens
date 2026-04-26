defmodule FramelensWeb.Admin.ObanJobLive do
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
      worker: %{
        module: Backpex.Fields.Text,
        label: "Worker",
        except: [:new, :edit]
      },
      queue: %{
        module: Backpex.Fields.Text,
        label: "Queue"
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

  def filters do
    [
      state: %{
        module: FramelensWeb.Admin.ObanJobLive.MultiJobStateSelect,
        label: "Tags",
        opts: [
          placeholder: "Selecione tags..."
        ]
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
    # def options, do: [
    #   {"John Doe", "acdd1860-65ce-4ed6-a37c-433851cf68d7"},
    #   {"Jane Doe", "9d78ce5e-9334-4a6c-a076-f1e72522de2"}
    #

    def options(_), do: Oban.Job.states() |> Enum.map(&{Atom.to_string(&1), Atom.to_string(&1)})
  end

  defp get_state_class(%{ state: state }) when state == "completed", do: "text-green-300 bg-green-900/50"
  defp get_state_class(%{ state: state }) when state in ["available",  "retryable",  "executing",  "scheduled"], do: "text-yellow-300 bg-yellow-900/50"
  defp get_state_class(%{ state: state }) when state in ["suspended", "cancelled", "discarded"], do: "text-red-300 bg-red-900/50"
  defp get_state_class(_), do: ""
end
