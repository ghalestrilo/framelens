defmodule FramelensWeb.Admin.ObanJobLive do
  use Backpex.LiveResource,
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

  def changeset(job, attrs, _metadata) do
    import Ecto.Changeset
    job
    |> cast(attrs, [:queue, :max_attempts, :priority])
    |> validate_required([:queue])
  end
end
