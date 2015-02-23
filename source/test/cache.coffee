should = require 'should'
Cache = require '../cache'

describe 'Cache', ->
  describe 'Instance', ->
    it 'should have size property', ->
      (new Cache).size.should.be.an.instanceOf Number

    it 'should have keys property', ->
      (new Cache).keys.should.be.an.instanceOf Array

    it 'should have items property', ->
      (new Cache).items.should.be.an.instanceOf Object

  describe '#constructor()', ->
    it 'should create the cache with DEFAULT_SIZE', ->
      (new Cache).size.should.be.equal Cache.DEFAULT_SIZE

    it 'should create the cache with provided size', ->
      (new Cache 10).size.should.be.equal 10

  describe '#trim()', ->
    it 'should trim the cache', ->
      cache = new Cache 2
      cache.add 'foo', 'bar'
      cache.add 'bar', 'foo'
      cache.trim 1
      cache.keys[0].should.be.equal 'bar'
      cache.items.bar.should.be.equal 'foo'

  describe '#resize()', ->
    it 'should resize the cache', ->
      cache = new Cache 2
      cache.add 'foo', 'bar'
      cache.add 'bar', 'foo'
      cache.resize 1
      cache.keys[0].should.be.equal 'bar'
      cache.items.bar.should.be.equal 'foo'

  describe '#add(key, value)', ->
    it 'should add the key-value pair to the cache', ->
      cache = new Cache
      cache.add 'foo', 'bar'
      cache.items.foo.should.be.equal 'bar'
      cache.keys[0].should.be.equal 'foo'

    it 'should trim the cache', ->
      cache = new Cache 1
      cache.add 'foo', 'bar'
      cache.add 'bar', 'foo'
      cache.keys[0].should.be.equal 'bar'
      cache.items.bar.should.be.equal 'foo'

    it 'should emit "add" event', (done) ->
      cache = new Cache
      cache.on 'add', -> done()
      cache.add 'foo', 'bar'

    it 'should emit "full" event', (done) ->
      cache = new Cache 1
      cache.on 'full', -> done()
      cache.add 'foo', 'bar'

    it 'should set "isFull" flag', ->
      cache = new Cache 1
      cache.isFull.should.be.equal false
      cache.add 'foo', 'bar'
      cache.isFull.should.be.equal true

    it 'should emit "trim" event', (done) ->
      cache = new Cache 1
      cache.add 'foo', 'bar'
      cache.on 'trim', -> done()
      cache.add 'bar', 'foo'

  describe '#remove(key)', ->
    it 'should remove the key-value pair from the cache', ->
      cache = new Cache 1
      cache.add 'foo', 'bar'
      cache.remove 'foo'
      should(cache.keys[0]).not.be.equal 'foo'
      should(cache.items.foo).not.be.ok

    it 'should emit "drain" event', (done) ->
      cache = new Cache 1
      cache.add 'foo', 'bar'
      cache.on 'drain', -> done()
      cache.remove 'foo', 'bar'

  describe '#get(key)', ->
    it 'should return the value', ->
      cache = new Cache 1
      cache.add 'foo', 'bar'
      (cache.get 'foo').should.be.equal 'bar'
