should = require 'should'

TestSplit = (require '../index').simple.Split
TestJoin = (require '../index').simple.Join

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
    join.on 'error', (error) ->
      (new Error 'Cache is full').toString().should.be.equal error.toString()
      done()
    split.write 'foobar'
