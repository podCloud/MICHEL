defmodule Michel.Stats.Commands.VisitFeed do
  defstruct [
    :id,
    :track_id,
    :feed_id,
    :user_agent,
    :referer,
    :country,
    :region,
    :city,
    :created_at
  ]
end
