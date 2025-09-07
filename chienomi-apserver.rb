#!/usr/bin/ruby
require 'rubygems'
require 'bundler/setup'
require 'roda'
require 'json'
require 'puma'
require 'rackup'
require 'rack/handler/puma'
require_relative "ap_config"
require_relative "ap_objects"

class ActivityPubApp < Roda
  AP_CONTENT_TYPE = "application/jrd+json"
  
  plugin :public,
    root: STATIC_PUBLIC_ROOT,
    default_mime: AP_CONTENT_TYPE
  
  route do |r|
    r.get ".well-known/webfinger" do
      resource = r.params["resource"]
      if resource == "acct:%s" % AP_ID
        response["Content-Type"] = AP_CONTENT_TYPE
        CHIENOMI_AP_OBJECTS[:webfinger].to_json
      else
        response.status = 404
        ""
      end
    end
    
    r.public
  end
end

Rackup::Handler::Puma.run ActivityPubApp.app, Host: SERVER_HOST, Port: SERVER_PORT
