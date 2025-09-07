require_relative "ap_config"

INITIAL_OUTBOX_DATA = {
  "@context": "https://www.w3.org/ns/activitystreams",
  id: [COLLECTION_PREFIX, "outbox"].join("/"),
  type: "OrderedCollection",
  totalItems: 0,
  first: BASE_COLLECTION_DATA[:id],
}