should = require 'should'
stream = require 'stream'
Split = (require '../index').Split

class TestSplit extends Split
  split: (obj) ->
    if @cache.isFull then throw new Error 'Cache is full'
    chunksId = Math.random().toString(36)
    @cache.add chunksId, (JSON.stringify obj).match /../g
    return chunksId

describe 'Split Stream', ->
  it 'should pipe out the object split into packets', ->
    split = new TestSplit
    test = (JSON.stringify 'foobar').match /../g
    split.write 'foobar'
    i = 0
    while packet = split.read()
      packet.toString().should.be.equal test[i++]
    i.should.not.be.equal 0

  it 'should reject new objects when cache is full', (done) ->
    split = new TestSplit cacheSize:1
    split.push = -> false
    split.write 'foobar'
    split.on 'error', (error) ->
      (new Error 'Cache is full').toString().should.be.equal error.toString()
      done()
    split.write 'foobar'


