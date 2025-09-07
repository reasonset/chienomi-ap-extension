#!/usr/bin/ruby
require 'rubygems'
require 'bundler/setup'
require 'oj'
require 'orbitalqueue'
require_relative 'ap_objects'
require_relative 'ap_config'
require_relative 'ap_utils'

Oj.default_options = {mode: :compat}

class APFollowed
  FOLLOWERS_PATH = [STATIC_PUBLIC_ROOT, ACTOR_BASEPATH, "followers"].join("/")
  FOLLOWERS_FILE = [FOLLOWERS_PATH, "followers"].join("/")
  FOLLOWERS_ASSOC = [FOLLOWERS_PATH, "followers_assoc.json"].join("/")
  FOLLOWERS_COLLECTIONS_TEMPLATE = [FOLLOWERS_PATH, "collection-%d"].join("/")
  SANITALIZED_FOLLOWERS_COLLECTION_DATA = Oj.load Oj.dump BASE_FOLLOWERS_COLLECTION_DATA
  SANITALIZED_ACCEPT_DATA = Oj.load Oj.dump BASE_ACCEPT_OBJECT
  FOLLOWERS_COLLECTION_SIZE = 10

  class FollowingObjectNotMatchError < StandardError
  end

  class InvalidActivityError < StandardError
  end

  class AlreadyFollowedError < StandardError
  end

  def self.initialize_dir
    unless File.exist? FOLLOWERS_COLLECTIONS_TEMPLATE % 1
      File.open((FOLLOWERS_COLLECTIONS_TEMPLATE % 1), "w") do |f|
        collection = SANITALIZED_FOLLOWERS_COLLECTION_DATA.clone
        collection["id"] = collection["id"] % 1
        f.write Oj.dump collection
      end
    end
    unless File.exist? FOLLOWERS_ASSOC
      File.open(FOLLOWERS_ASSOC, "w") {|f| f.write Oj.dump({})}
    end
  end

  def initialize(activity)
    # {
    #   "@context": "https://www.w3.org/ns/activitystreams",
    #   "id": "https://yourdomain/activity/abc123",
    #   "type": "Follow",
    #   "actor": "https://example.com/users/alice",
    #   "object": "https://yourdomain/users/bloggy"
    # }
    @activity = activity

    unless activity["object"] == ACTOR_URL
      raise FollowingObjectNotMatchError
    end

    unless activity["@context"] == "https://www.w3.org/ns/activitystreams" && activity["type"] == "Follow" && activity["actor"]
      raise InvalidActivityError
    end

    if !activity["id"]
      ChienomiAPUtils.create_activity! activity
    end

    @assoc = Oj.load File.read FOLLOWERS_ASSOC
    # @queue = OrbitalQueue.new([JOBQUEUE_ROOT, "follow"].join("/"), true)
    @queue_out = OrbitalQueue.new([JOBQUEUE_ROOT, "apout"].join("/"), true)
  end

  def follow
    followers = Oj.load File.read FOLLOWERS_FILE
    latest_index = (followers["totalItems"] / FOLLOWERS_COLLECTION_SIZE).succ
    latest_collection_path = FOLLOWERS_COLLECTIONS_TEMPLATE % latest_index
    latest_collection = Oj.load File.read(latest_collection_path)

    if @assoc[@activity["actor"]]
      raise AlreadyFollowedError
    end

    save_followers followers, latest_collection, latest_collection_path

    if latest_collection["orderedItems"].size >= FOLLOWERS_COLLECTION_SIZE
      increase_collection latest_collection
    end

    save_assoc

    enqueue
  end

  def save_followers followers, latest_collection, latest_collection_path
    followers["totalItems"] += 1
    latest_collection["orderedItems"].push @activity["actor"]

    File.open(FOLLOWERS_FILE, "w") {|f| f.write Oj.dump followers }
    File.open(latest_collection_path, "w") {|f| f.write Oj.dump latest_collection }
  end

  def increase_collection latest_collection
    latest_collection["id"] =~ /(\d+)$/
    latest_part = $1.to_i
    next_collection = SANITALIZED_FOLLOWERS_COLLECTION_DATA.clone
    next_part = latest_part.succ
    next_collection["next"] = latest_collection["id"]
    next_collection["id"] = next_collection["id"] % next_part
    File.open((FOLLOWERS_COLLECTIONS_TEMPLATE % next_part), "w") do |f|
      f.write Oj.dump next_collection
    end
  end

  def save_assoc
    @assoc[@activity["actor"]] = true
    File.open(FOLLOWERS_ASSOC, "w") {|f| f.write Oj.dump @assoc}
  end

  def enqueue
    accept = SANITALIZED_ACCEPT_DATA.clone
    accept["object"] = @activity
    ChienomiAPUtils.create_activity! accept, prefix: "accept"

    @queue_out.push accept
  end
end

# TEST!!
APFollowed.initialize_dir
(1..25).each do |i|
  test_object = Oj.load Oj.dump({
    "@context": "https://www.w3.org/ns/activitystreams",
    "type": "Follow",
    "actor": "https://example.com/users/alice#{i}",
    "object": ACTOR_URL
  })

  ap = APFollowed.new(test_object)
  ap.follow
end