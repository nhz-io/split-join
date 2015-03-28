module.exports = class Join extends require '../join'
  regexp = /^([^\s]+)\s+([^\s]+)\s+([^\s]+)\s*?\n\n(.+)$/m
  join: (packet) ->
    if parsed = packet.toString().match regexp
      [id, index, total, chunk] = parsed[1..4]
    unless chunks = @cache.get id
      if @cache.isFull then throw new Error 'Cache is full'
      @cache.add id, chunks = []
    chunks.push chunk
    if (parseInt index) + 1 is (parseInt total)
      return id
    return
