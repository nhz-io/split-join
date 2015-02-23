stream = require 'stream'
Cache = require './cache'

module.exports = class Split extends stream.Transform
  constructor: (options = {}) ->
    cacheSize = options.cacheSize or options.highWaterMark or 16
    @cache = new Cache cacheSize
    options.objectMode = true
    super options

  pushChunks: (chunksId, nextId = 0) ->
    chunks = @cache.get chunksId
    while @push chunks[nextId++]
      if nextId >= chunks.length
        @cache.remove chunksId
        return
    @once 'drain', => @pushChunks chunksId, nextId
    return

  _transform: (obj, encoding, callback) ->
    try
      @pushChunks @split obj, encoding
      callback()
    catch error
      callback error
    return
