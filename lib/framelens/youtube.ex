defmodule Framelens.YouTube do
  @moduledoc """
  Thin wrapper around the YouTube Data API v3 for creator discovery.
  """

  @search_url "https://www.googleapis.com/youtube/v3/search"
  @max_results 150

  @doc """
  Returns up to `@max_results` distinct channels whose videos rank highest by
  view count for `query`. Searches videos (not channels) so that `order=viewCount`
  is honoured by the API, then extracts the owning channel from each result.
  """
  def search_channels(query) do
    api_key = Application.fetch_env!(:framelens, :youtube_api_key)

    case Req.get(@search_url,
           params: [
             part: "snippet",
             type: "video",
             q: query,
             maxResults: @max_results,
             order: "viewCount",
             key: api_key
           ]
         ) do
      {:ok, %{status: 200, body: body}} ->
        channels =
          body
          |> Map.get("items", [])
          |> Enum.map(fn item ->
            %{
              name: get_in(item, ["snippet", "channelTitle"]),
              channel_id: get_in(item, ["snippet", "channelId"])
            }
          end)
          |> Enum.reject(fn %{name: n, channel_id: id} -> is_nil(n) or is_nil(id) end)
          |> Enum.uniq_by(& &1.channel_id)

        {:ok, channels}

      {:ok, %{status: status, body: body}} ->
        {:error, "YouTube API error #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
