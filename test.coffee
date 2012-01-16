testCount = 0
passed = 0
failed = 0

logEl = document.getElementById 'log'

log = (args...) ->
  console.log.apply console, arguments
  txtNode = document.createTextNode "\n#{args.join(' ')}"
  logEl.appendChild txtNode

equal = (a, b, description) ->
  testCount++
  if a is b
    log 'ok', description
    passed++
  else
    log 'not ok', description, 'expected', b, 'got', a
    failed++

# clear it all out first
localStorage.removeItem 'fifo:test'

# helpers to create a bunch of data
repeat = (str, n) ->
  a = []
  while n--
    a.push str
  a.join ''

n10b  = '0123456789'
n100b = repeat n10b, 10
n1k   = repeat n100b, 10
n10k  = repeat n1k, 10
n100k = repeat n10k, 10
n1m   = repeat n100k, 10

# measure how long it all takes
start = +new Date()

# create our collection
collection = fifo 'fifo:test'

# test: set and get
collection.set 'foo', {foo: 'bar'}
retrieved = collection.get 'foo'
equal retrieved.foo, 'bar', 'set and get'

# test: remove
collection.remove 'foo'
retrieved = collection.get 'foo'
equal retrieved, undefined, 'item removed'

# test: ensure it removes old items to add others, sending them to onLimit
limitReached = false
removedItem = null
i = 0
onLimit = (items) ->
  limitReached = true
  removedItem = items[0]
until limitReached or i is 10000 # don't wan't to freeze the browser
  i++
  key = "test:#{i}"
  collection.set key, n100k, onLimit
equal removedItem.key, "test:1", 'removed first item when quota met'

# test: empty
collection.set 'empty1', true
collection.set 'empty2', true
equal collection.get('empty1'), true, 'empty1 exists'
equal collection.get('empty2'), true, 'empty2 exists'
collection.empty()
equal collection.get('empty1'), undefined, 'empty1 emptied'
equal collection.get('empty2'), undefined, 'empty2 emptied'

# report
status = if failed is 0 then 'ok' else 'not ok'
log "\n#{status}", "#{passed}/#{testCount}"

end = +new Date()
log 'finished in:', end - start, 'ms'

