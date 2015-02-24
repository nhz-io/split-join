# Split -> Join Streams

A pair of streams and a cache to facilitate serialization
and deserialization of javascript objects.

## Classes
* Split
* Join
* Cache

### Split - abstract interface (stream)
This class must be extended and `split(obj)` method must be implemented.
The `split(obj)` method must serialize the `obj` into array of packets
and the result must be cached with unique ID string. Must return the ID.

### Join - abstract interface (stream)
This class must be extended and `join(packet)` method must be implemented.
At every execution the `join(packet)` method must create an array of the
chunks which make up the original `obj` and cache it with unique ID string.
If the array contains enough packets to reassemble the original `obj`, the
`join(packet)` method must return the ID, otherwise, it must return `null`

## Usage (CoffeeScript)

### Implement Split
```coffeescript
class Split extends (require 'split-join').Split
  split: (obj) ->
    if @cache.isFull then throw new Error 'Cache is full'
    chunksId = Math.random().toString(36)
    @cache.add chunksId, chunks = (JSON.stringify obj).match /.{1,256}/g
    total = chunks.length
    for chunk, index in chunks
      chunks[index] = "#{chunksId} #{index} #{total}\n\n#{chunk}"
    return chunksId
```

### Implement Join
```coffeescript
class Join extends (require 'split-join').Join
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
    return
```

### Sender
```coffeescript
socket = getSocketSomehow()
split = new Split
split.pipe socket

# serialize the array into packets and send them out
split.write [ 'data', 'from', 'sender' ]
```

### Receiver
```coffeescript
socket = getSocketSomehow()
join = new Join
socket.pipe join

# the data coming from join will be the array from the sender
```

[![Build Status][travis-image]][travis-url]

[![NPM][npm-image]][npm-url]

[travis-image]: https://travis-ci.org/nhz-io/split-join.svg
[travis-url]: https://travis-ci.org/nhz-io/split-join

[npm-image]: https://nodei.co/npm/split-join.png
[npm-url]: https://nodei.co/npm/split-join
