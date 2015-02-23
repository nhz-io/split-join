stream = require 'stream'
Cache = require './cache'

module.exports = class Join extends stream.Transform
  constructor: (options = {}) ->
    cacheSize = options.cacheSize or options.highWaterMark or 16
    @cache = new Cache cacheSize
    @canPush = true
    options.objectMode = true
    super options

  pushObject: (chunksId) ->
    chunks = @cache.get chunksId
    if @canPush
      @canPush = @push JSON.parse (@cache.get chunksId).join ''
      @cache.remove chunksId
    else
      @once 'drain', =>
        @canPush = true
        @pushObject chunksId, nextId

  _transform: (packet, encoding, callback) ->
    try
      if chunksId = @join packet, encoding
        @pushObject chunksId
      callback()
    catch error
      callback error
    return
