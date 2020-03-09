defmodule Michel.Stats.Commands.DownloadEnclosure do
  defstruct [
    :id,
    :track_id,
    :feed_id,
    :item_id,
    :source,
    :user_agent,
    :referer,
    :country,
    :region,
    :city,
    :created_at
  ]
end
