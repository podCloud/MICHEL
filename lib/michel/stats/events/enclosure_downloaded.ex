defmodule Michel.Stats.Events.EnclosureDownloaded do
  @derive Jason.Encoder
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
