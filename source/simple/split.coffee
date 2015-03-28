module.exports = class Split extends require '../split'
  split: (obj) ->
    if @cache.isFull then throw new Error 'Cache is full'
    chunksId = Math.random().toString(36)
    @cache.add chunksId, chunks = (JSON.stringify obj).match /.{1,1024}/g
    total = chunks.length
    for chunk, index in chunks
      chunks[index] = "#{chunksId} #{index} #{total}\n\n#{chunk}"
    return chunksId
