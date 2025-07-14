#!/usr/bin/ruby
require 'rubygems'
require 'bundler/setup'
require 'oj'
require 'time'
require 'digest/sha2'
require_relative 'ap_objects'
require_relative 'ap_config'

Oj.default_options = {mode: :compat}

title = ARGV.shift
link = ARGV.shift

abort "craete-apevent.rb <title> <link>" unless title && link

OUTBOX_PATH = [STATIC_DB_OUTBOX, "outbox.json"].join("/")
COLLECTION_GLOB = [STATIC_DB_OUTBOX, "collection-*.json"].join("/")

# Automatic initialize
unless File.exist? OUTBOX_PATH
  require_relative 'ap_configured_objects'
  require 'fileutils'
  STDERR.puts "Initialize AP Database..."
  FileUtils.mkdir_p STATIC_DB_ROOT unless File.exist? STATIC_DB_ROOT
  Dir.mkdir STATIC_DB_OUTBOX unless File.exist? STATIC_DB_OUTBOX
  Dir.mkdir STATIC_DB_CREATES unless File.exist? STATIC_DB_CREATES
  Dir.mkdir STATIC_DB_NOTES unless File.exist? STATIC_DB_NOTES
  File.open(OUTBOX_PATH, "w") {|f| f.write Oj.dump INITIAL_OUTBOX_DATA}
  File.open([STATIC_DB_OUTBOX, "collection-1.json"].join("/"), "w") {|f| f.write Oj.dump BASE_COLLECTION_DATA}
end

collections = Dir.glob(COLLECTION_GLOB)
latest_collection = collections.max_by {|i| File.basename(i, ".*").sub("collection-", "").to_i }
number_of_collections = collections.size
latest_data = Oj.load File.read latest_collection
outbox = Oj.load File.read OUTBOX_PATH

ap_obejct_id = Digest::SHA256.hexdigest(ID_DIGEST_SALT + link)
now = Time.now
now_xml = now.xmlschema

create = Oj.load(Oj.dump(BASE_CREATE_DATA))
note = Oj.load(Oj.dump(BASE_NOTE_DATA))

page_next = false

create["published"] = now_xml
note["published"] = now_xml
note["url"] = link
note["content"] = title

create["id"] = sprintf(create["id"], ap_obejct_id)
note["id"] = sprintf(note["id"], ap_obejct_id)

create_filepath = "#{STATIC_DB_CREATES}/#{File.basename create["id"]}.json"
note_filepath = "#{STATIC_DB_NOTES}/#{File.basename note["id"]}.json"

# Check already exist
if File.exist? note_filepath
  abort "Article #{link} is already exist."
end

create_outbox = create.clone

create["object"] = note["id"]
create_outbox["object"] = note

latest_data["orderedItems"].push create_outbox
outbox["totalItems"] = 20 * (number_of_collections - 1) + latest_data["orderedItems"].size

page_next = true if latest_data["orderedItems"].size >= 20

File.open(create_filepath, "w") {|f| f.write Oj.dump create }
File.open(note_filepath, "w") {|f| f.write Oj.dump note }

outbox["first"] = outbox["first"].sub(/\.json$/, "").succ + ".json" if page_next

File.open(OUTBOX_PATH, "w") {|f| f.write Oj.dump outbox }
File.open(latest_collection, "w") {|f| f.write Oj.dump latest_data }

if page_next
  next_collection = latest_collection.sub(/\.json$/, "").succ + ".json"
  next_collection_data = BASE_COLLECTION_DATA.clone
  next_collection_data["next"] = [COLLECTION_PREFIX, File.basename(latest_collection)]
  File.open(next_collection, "w") {|f| f.write Oj.dump next_collection_data }
end
