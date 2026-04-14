defprotocol Framelens.Platform do
  @doc """
  Fetches all available content for this platform entry.
  Returns {:ok, [entry]} or {:error, reason}.
  Each entry is expected to have at least: :title, :url, :author, :updated
  """
  def fetch_content(platform)
end
