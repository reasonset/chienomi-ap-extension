require_relative 'ap_config'

CHIENOMI_AP_OBJECTS = {
  webfinger: {
    "subject": "acct:#{AP_ID}",
    "links": [
      {
        "rel": "self",
        "type": "application/activity+json",
        "href": "https://#{AP_HOSTNAME}/ap/users/#{ACTOR_ID}/actor"
      }
    ]
  }
}

BASE_COLLECTION_DATA = {
  "@context": "https://www.w3.org/ns/activitystreams",
  "id": "https://#{AP_HOSTNAME}/ap/users/#{ACTOR_ID}/outbox/collection-%d",
  "type": "OrderedCollectionPage",
  "partOf": "https://#{AP_HOSTNAME}/ap/users/#{ACTOR_ID}/outbox/outbox",
  "orderedItems": []
}

BASE_CREATE_DATA = {
  "@context": "https://www.w3.org/ns/activitystreams",
  id: "https://#{AP_HOSTNAME}/ap/users/#{ACTOR_ID}/creates/%s",
  "type": "Create",
  "actor": ACTOR_URL,
  published: nil,
  "to": ["https://www.w3.org/ns/activitystreams#Public"],
  object: nil
}

BASE_NOTE_DATA = {
  "@context": "https://www.w3.org/ns/activitystreams",
  id: "https://#{AP_HOSTNAME}/ap/users/#{ACTOR_ID}/notes/%s",
  "type": "Note",
  "attributedTo": ACTOR_URL,
  content: nil,
  url: nil,
  published: nil
}

BASE_FOLLOWERS_COLLECTION_DATA = {
  "@context": "https://www.w3.org/ns/activitystreams",
  "id": "https://#{AP_HOSTNAME}/ap/users/#{ACTOR_ID}/followers/collection-%d",
  "type": "OrderedCollectionPage",
  "partOf": "https://#{AP_HOSTNAME}/ap/users/#{ACTOR_ID}/followers",
  "orderedItems": []
}

BASE_FOLLOWERS_COLLECTION_DATA_ID_TEMPLATE = "https://#{AP_HOSTNAME}/ap/users/#{ACTOR_ID}/followers/collection-%d"

BASE_ACCEPT_OBJECT = {
  "@context": "https://www.w3.org/ns/activitystreams",
  "type": "Accept",
  "actor": AP_ID,
  "object": nil
}
