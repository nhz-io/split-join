should = require 'should'
stream = require 'stream'
Join = require '../join'
Split = require '../split'

class TestSplit extends Split
  split: (obj) ->
    if @cache.isFull then throw new Error 'Cache is full'
    chunksId = Math.random().toString(36)
    @cache.add chunksId, chunks = (JSON.stringify obj).match /.{1,2}/g
    total = chunks.length
    for chunk, index in chunks
      chunks[index] = "#{chunksId} #{index} #{total}\n\n#{chunk}"
    return chunksId

class TestJoin extends Join
  regexp = /^([^\s]+)\s+([^\s]+)\s+([^\s]+)\s*?\n\n(.+)$/m
  join: (packet) ->
    if parsed = packet.match regexp
      [id, index, total, chunk] = parsed[1..4]
    unless chunks = @cache.get id
      if @cache.isFull then throw new Error 'Cache is full'
      @cache.add id, chunks = []
    chunks.push chunk
    if (parseInt index) + 1 is (parseInt total)
      return id
    undefined

describe 'Join Stream', ->
  it 'should reassemble the original objects piped in from Split stream', (done) ->
    split = new TestSplit
    join = new TestJoin
    split.pipe join

    split.write "foobar", ->
      join.read().should.be.equal "foobar"
      done()

  it 'should reject new packets when cache is full', (done) ->
    split = new TestSplit
    join = new TestJoin cacheSize:1
    join.push = -> false
    join.cache.add 'foo', 'bar'
    split.pipe join
    split.write 'foobar'
    join.on 'error', (error) ->
      (new Error 'Cache is full').toString().should.be.equal error.toString()
      done()
