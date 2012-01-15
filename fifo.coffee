# UMD Boilerplate \o/ && D:
((root, factory) ->
  if define?.amd
    define factory
  else
    _fifo = root.fifo
    fifo = root.fifo = factory()
    fifo.noConflict = ->
      root.fifo = _fifo
      fifo
)(this, ->

  (namespace) ->

    data = JSON.parse localStorage.getItem(namespace) or '{"keys":[],"items":{}}'

    trySave = ->
      json = JSON.stringify data
      try
        localStorage.setItem namespace, json
      catch error
        if error.name is 'QUOTA_EXCEEDED_ERR'
          return false
        else
          throw new Error error
      true

    removeFirstIn = ->
      firstIn = data.keys.pop()
      removedItem = key: firstIn, value: data.items[firstIn]
      delete data.items[firstIn]
      removedItem

    save = ->
      removed = []
      until trySave()
        if data.keys.length
          removed.push removeFirstIn()
        else
          throw new Error "All items removed from #{namespace}, still can't save"
          break
      removed

    set: (key, value, onRemoved) ->
      data.items[key] = value
      data.keys.unshift key
      removed = save()
      onRemoved.call this, removed if onRemoved and removed.length
      this

    # no args returns all items
    get: (key) ->
      if key
        data.items[key]
      else
        data.items

    remove: (victim) ->
      for suspect, index in data.keys when suspect is victim
        data.keys.splice index, 1
        break
      delete data.items[victim]
      save()
      this

    empty: ->
      data = keys: [], items: {}
      save()
      this
)
