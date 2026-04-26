defprotocol Framelens.Platform do
  @doc """
  Fetches all available content for this platform entry.
  Returns {:ok, [entry]} or {:error, reason}.
  Each entry is expected to have at least: :title, :url, :author, :updated
  """
  def fetch_content(platform)
end

defmodule Framelens.Platform.Registry do
  @platforms %{
    "youtube"   => %{module: Framelens.Platform.YouTube,   label: "YouTube",   placeholder: "e.g. UCsBjURrPoezykLs9EqgamOA"},
    "facebook"  => %{module: Framelens.Platform.Facebook,  label: "Facebook",  placeholder: "e.g. Fireship"},
    "instagram" => %{module: Framelens.Platform.Instagram, label: "Instagram", placeholder: "e.g. fireship.io"},
    "tiktok"    => %{module: Framelens.Platform.TikTok,    label: "TikTok",    placeholder: "e.g. @fireship"},
    "twitter"   => %{module: Framelens.Platform.Twitter,   label: "X/Twitter", placeholder: "e.g. fireship_dev"}
  }

  def all, do: @platforms

  def get_module(name), do: Map.fetch!(@platforms, name).module
  def get_name(module) do
    {key, _} = Enum.find(@platforms, fn {_, v} -> v.module == module end)
    key
  end
end
