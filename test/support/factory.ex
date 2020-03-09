defmodule Michel.Factory do
  use ExMachina

  alias Michel.Stats.Commands.{VisitFeed, DownloadEnclosure}
  alias Michel.Stats.Events.{FeedVisited, EnclosureDownloaded}

  def view_factory do
    %{
      id: UUID.uuid4(),
      track_id: "a066be58-96b2-4fc8-9681-cec88df64941",
      feed_id: "fe113110-a5c2-43d7-87bd-472d5e78d460",
      user_agent: "iTunes",
      referer: "https://blabla.com/gfdgfdf",
      country: "France",
      region: "Occitanie",
      city: "Toulouse",
      created_at: "2020-03-05T19:20:30.45+01:00"
    }
  end

  def download_factory do
    %{
      id: UUID.uuid4(),
      track_id: "a066be58-96b2-4fc8-9681-cec88df64941",
      feed_id: "fe113110-a5c2-43d7-87bd-472d5e78d460",
      item_id: "c7968748-c76d-4941-8c32-202a3a931190",
      source: "podcloud",
      user_agent: "iTunes",
      referer: "https://blabla.com/gfdgfdf",
      country: "France",
      region: "Occitanie",
      city: "Toulouse",
      created_at: "2020-03-05T19:20:30.45+01:00"
    }
  end

  def visit_feed_factory(attrs \\ %{}) do
    struct(VisitFeed, build(:view, attrs))
  end

  def feed_visited_factory(attrs \\ %{}) do
    struct(FeedVisited, build(:view, attrs))
  end

  def download_enclosure_factory(attrs \\ %{}) do
    struct(DownloadEnclosure, build(:download, attrs))
  end

  def enclosure_downloaded_factory(attrs \\ %{}) do
    struct(EnclosureDownloaded, build(:download, attrs))
  end
end
