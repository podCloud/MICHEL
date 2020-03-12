defmodule Michel.Stats.StatsTest do
  use Michel.DataCase

  alias Michel.Stats
  alias Michel.Repo
  alias Michel.Stats.Projections.{UniqueVisit, UniqueDownload, FeedVisit, EnclosureDownload}

  describe "Register feed visit with deduplication" do
    test "should create unique visit if none exists for a given track_id" do
      track_id = UUID.uuid4()

      assert {:ok, %UniqueVisit{} = visit} = Stats.visit_feed(build(:view, track_id: track_id))
      assert visit.track_id == track_id
    end

    test "should not update visit if same track_id in less than 24h interval" do
      track_id = UUID.uuid4()

      Stats.visit_feed(build(:view, track_id: track_id, created_at: "2020-03-06T17:00:00.45"))

      assert {:ok, %UniqueVisit{} = visit} =
               Stats.visit_feed(
                 build(:view, track_id: track_id, created_at: "2020-03-07T16:59:59.45")
               )

      assert visit.track_id == track_id
      assert visit.created_at == ~N[2020-03-06 17:00:00]
    end

    test "should update visit if same track_id in a 24h interval or more" do
      track_id = UUID.uuid4()

      Stats.visit_feed(build(:view, track_id: track_id, created_at: "2020-03-06T17:00:00.45"))

      assert {:ok, %UniqueVisit{} = visit} =
               Stats.visit_feed(
                 build(:view, track_id: track_id, created_at: "2020-03-07T17:00:00.45")
               )

      assert visit.track_id == track_id
      assert visit.created_at == ~N[2020-03-07 17:00:00]
    end
  end

  describe "Register enclosure download with deduplication" do
    test "should create unique download if none exists for a given track_id" do
      track_id = UUID.uuid4()

      assert {:ok, %UniqueDownload{} = download} =
               Stats.download_enclosure(build(:download, track_id: track_id))

      assert download.track_id == track_id
    end

    test "should not update download if same track_id in less than 24h interval" do
      track_id = UUID.uuid4()

      Stats.download_enclosure(
        build(:download, track_id: track_id, created_at: "2020-03-06T17:00:00.45")
      )

      assert {:ok, %UniqueDownload{} = download} =
               Stats.download_enclosure(
                 build(:download, track_id: track_id, created_at: "2020-03-07T16:59:59.45")
               )

      assert download.track_id == track_id
      assert download.created_at == ~N[2020-03-06 17:00:00]
    end

    test "should update download if same track_id in a 24h interval or more" do
      track_id = UUID.uuid4()

      Stats.download_enclosure(
        build(:download, track_id: track_id, created_at: "2020-03-06T17:00:00.45")
      )

      assert {:ok, %UniqueDownload{} = download} =
               Stats.download_enclosure(
                 build(:download, track_id: track_id, created_at: "2020-03-07T17:00:00.45")
               )

      assert download.track_id == track_id
      assert download.created_at == ~N[2020-03-07 17:00:00]
    end
  end

  describe "handle feed visits counter" do
    test "should create a daily count of 1 for a unique track_id" do
      feed_id = UUID.uuid4()

      Stats.visit_feed(build(:view, feed_id: feed_id, created_at: "2020-03-10T17:00:00.45"))

      stats = Repo.get_by!(FeedVisit, feed_id: feed_id, type: "daily", date: "2020-03-10")
      assert stats.count == 1
    end

    test "should create a daily count of 3 for three unique track_id" do
      feed_id = UUID.uuid4()

      Stats.visit_feed(
        build(:view, feed_id: feed_id, track_id: "1", created_at: "2020-03-10T17:00:00.45")
      )

      Stats.visit_feed(
        build(:view, feed_id: feed_id, track_id: "2", created_at: "2020-03-10T17:00:00.45")
      )

      Stats.visit_feed(
        build(:view, feed_id: feed_id, track_id: "3", created_at: "2020-03-10T17:00:00.45")
      )

      Stats.visit_feed(
        build(:view, feed_id: feed_id, track_id: "1", created_at: "2020-03-11T16:59:59.45")
      )

      stats = Repo.get_by!(FeedVisit, feed_id: feed_id, type: "daily", date: "2020-03-10")
      assert stats.count == 3
    end

    test "should create a monthly count of 1 for a unique track_id" do
      feed_id = UUID.uuid4()

      Stats.visit_feed(build(:view, feed_id: feed_id, created_at: "2020-03-10T17:00:00.45"))

      stats = Repo.get_by!(FeedVisit, feed_id: feed_id, type: "monthly", date: "2020-03-01")
      assert stats.count == 1
    end

    test "should create a monthly count of 3 for 3 daily uniques track_ids" do
      feed_id = UUID.uuid4()

      Stats.visit_feed(
        build(:view, feed_id: feed_id, track_id: "1", created_at: "2020-03-10T17:00:00.45")
      )

      Stats.visit_feed(
        build(:view, feed_id: feed_id, track_id: "1", created_at: "2020-03-11T17:00:00.45")
      )

      Stats.visit_feed(
        build(:view, feed_id: feed_id, track_id: "1", created_at: "2020-03-12T17:00:00.45")
      )

      Stats.visit_feed(
        build(:view, feed_id: feed_id, track_id: "1", created_at: "2020-03-11T16:59:59.45")
      )

      stats = Repo.get_by!(FeedVisit, feed_id: feed_id, type: "monthly", date: "2020-03-01")
      assert stats.count == 3
    end

    test "should create a new daily count for each daily visits" do
      feed_id = UUID.uuid4()

      Stats.visit_feed(build(:view, feed_id: feed_id, created_at: "2020-03-10T17:00:00.45"))
      Stats.visit_feed(build(:view, feed_id: feed_id, created_at: "2020-03-11T17:00:00.45"))

      assert nil !=
               Repo.get_by!(FeedVisit, feed_id: feed_id, type: "daily", date: "2020-03-10")

      assert nil !=
               Repo.get_by!(FeedVisit, feed_id: feed_id, type: "daily", date: "2020-03-11")
    end

    test "should create a new daily count for each monthly visits" do
      feed_id = UUID.uuid4()

      Stats.visit_feed(build(:view, feed_id: feed_id, created_at: "2020-03-10T17:00:00.45"))
      Stats.visit_feed(build(:view, feed_id: feed_id, created_at: "2020-04-11T17:00:00.45"))

      assert nil !=
               Repo.get_by!(FeedVisit, feed_id: feed_id, type: "monthly", date: "2020-03-01")

      assert nil !=
               Repo.get_by!(FeedVisit, feed_id: feed_id, type: "monthly", date: "2020-04-01")
    end
  end

  describe "handle enclosure downloads counter" do
    test "should create a daily count of 1 for a unique track_id" do
      item_id = UUID.uuid4()
      source = "podcloud"

      Stats.download_enclosure(
        build(:download,
          item_id: item_id,
          source: source,
          created_at: "2020-03-10T17:00:00.45"
        )
      )

      stats =
        Repo.get_by!(EnclosureDownload,
          item_id: item_id,
          source: source,
          type: "daily",
          date: "2020-03-10"
        )

      assert stats.count == 1
    end

    test "should create a daily count of 3 for three unique track_id" do
      item_id = UUID.uuid4()
      source = "podcloud"

      Stats.download_enclosure(
        build(:download,
          item_id: item_id,
          source: source,
          track_id: "1",
          created_at: "2020-03-10T17:00:00.45"
        )
      )

      Stats.download_enclosure(
        build(:download,
          item_id: item_id,
          source: source,
          track_id: "2",
          created_at: "2020-03-10T17:00:00.45"
        )
      )

      Stats.download_enclosure(
        build(:download,
          item_id: item_id,
          source: source,
          track_id: "3",
          created_at: "2020-03-10T17:00:00.45"
        )
      )

      Stats.download_enclosure(
        build(:download,
          item_id: item_id,
          source: source,
          track_id: "1",
          created_at: "2020-03-11T16:59:59.45"
        )
      )

      stats =
        Repo.get_by!(EnclosureDownload,
          item_id: item_id,
          source: source,
          type: "daily",
          date: "2020-03-10"
        )

      assert stats.count == 3
    end

    test "should create a monthly count of 1 for a unique track_id" do
      item_id = UUID.uuid4()
      source = "podcloud"

      Stats.download_enclosure(
        build(:download,
          item_id: item_id,
          source: source,
          created_at: "2020-03-10T17:00:00.45"
        )
      )

      stats =
        Repo.get_by!(EnclosureDownload,
          item_id: item_id,
          source: source,
          type: "monthly",
          date: "2020-03-01"
        )

      assert stats.count == 1
    end

    test "should create a monthly count of 3 for 3 daily uniques track_ids" do
      item_id = UUID.uuid4()
      source = "podcloud"

      Stats.download_enclosure(
        build(:download,
          item_id: item_id,
          source: source,
          track_id: "1",
          created_at: "2020-03-10T17:00:00.45"
        )
      )

      Stats.download_enclosure(
        build(:download,
          item_id: item_id,
          source: source,
          track_id: "1",
          created_at: "2020-03-11T17:00:00.45"
        )
      )

      Stats.download_enclosure(
        build(:download,
          item_id: item_id,
          source: source,
          track_id: "1",
          created_at: "2020-03-12T17:00:00.45"
        )
      )

      Stats.download_enclosure(
        build(:download,
          item_id: item_id,
          source: source,
          track_id: "1",
          created_at: "2020-03-11T16:59:59.45"
        )
      )

      stats =
        Repo.get_by!(EnclosureDownload,
          item_id: item_id,
          source: source,
          type: "monthly",
          date: "2020-03-01"
        )

      assert stats.count == 3
    end

    test "should create a new daily count for each daily visits" do
      item_id = UUID.uuid4()
      source = "podcloud"

      Stats.download_enclosure(
        build(:download,
          item_id: item_id,
          source: source,
          created_at: "2020-03-10T17:00:00.45"
        )
      )

      Stats.download_enclosure(
        build(:download,
          item_id: item_id,
          source: source,
          created_at: "2020-03-11T17:00:00.45"
        )
      )

      assert nil !=
               Repo.get_by!(EnclosureDownload,
                 item_id: item_id,
                 source: source,
                 type: "daily",
                 date: "2020-03-10"
               )

      assert nil !=
               Repo.get_by!(EnclosureDownload,
                 item_id: item_id,
                 source: source,
                 type: "daily",
                 date: "2020-03-11"
               )
    end

    test "should create a new daily count for each monthly visits" do
      item_id = UUID.uuid4()
      source = "podcloud"

      Stats.download_enclosure(
        build(:download,
          item_id: item_id,
          source: source,
          created_at: "2020-03-10T17:00:00.45"
        )
      )

      Stats.download_enclosure(
        build(:download,
          item_id: item_id,
          source: source,
          created_at: "2020-04-11T17:00:00.45"
        )
      )

      assert nil !=
               Repo.get_by!(EnclosureDownload,
                 item_id: item_id,
                 source: source,
                 type: "monthly",
                 date: "2020-03-01"
               )

      assert nil !=
               Repo.get_by!(EnclosureDownload,
                 item_id: item_id,
                 source: source,
                 type: "monthly",
                 date: "2020-04-01"
               )
    end
  end
end
