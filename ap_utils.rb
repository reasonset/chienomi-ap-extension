require 'rubygems'
require 'bundler/setup'
require 'oj'
require 'securerandom'
require_relative 'ap_config'

module ChienomiAPUtils
  def self.create_activity! activity, prefix: nil
    prefix_str = prefix ? prefix + "-" : ""
    activity_path = [ACTOR_BASEPATH, "activity", (prefix_str + SecureRandom.uuid)].join("/")
    activity["id"] = [AP_HOSTNAME, activity_path].join("/")
    activity_filepath = [STATIC_PUBLIC_ROOT, activity_path].join("/")

    File.open(activity_filepath, "w") {|f| f.write Oj.dump activity}

    activity
  end
end