events = require 'events'

module.exports = class Cache extends events.EventEmitter
  @DEFAULT_SIZE = 1024
  constructor: (size = Cache.DEFAULT_SIZE) ->
    unless this instanceof Cache then return new Cache size
    @size = size
    @keys = []
    @items = {}
    @isFull = false

  resize: (@size = Cache.DEFAULT_SIZE) -> @trim()

  trim: (size = @size) ->
    if (excess = @keys.length - size) > 0
      for key in @keys.splice 0, excess
        @emit 'trim', key, @items[key]
        delete @items[key]
    return this

  get: (key) -> @items[key]

  add: (key, value) ->
    if @items.hasOwnProperty key
      @keys.splice (@keys.indexOf key), 1
    @keys.push key
    @emit 'add', key, value
    @items[key] = value
    if @keys.length is @size
      @isFull = true
      @emit 'full', key, value
    @trim()

  remove: (key) ->
    if @items.hasOwnProperty key
      @emit 'remove', key, @items[key]
      wasFull = @size >= @keys.length
      @keys.splice (@keys.indexOf key), 1
      value = @items[key]
      delete @items[key]
      if @keys.length is @size - 1
        @isFull = false
        @emit 'drain', key, value
    return this
