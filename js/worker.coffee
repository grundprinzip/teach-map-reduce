$ = 
  trim: (data) ->
    do data.trim


funs = []
self = this

extendFunction = (body) ->
  f = new Function(body)
  f::mapResult = {}
  f::reduceResult = []

  # Called by the map function
  f::emit = (key, value)->
    if !@mapResult[key]
      @mapResult[key] = []

    @mapResult[key].push value

  f::wrapMap = (data) ->
    start = new Date().getTime()
    for l in data
      this.map l 
      end = new Date().getTime()
    postMessage "Map -> #{end-start}ms / #{data.length}<br/>"

  f::wrapReduce = ->
    start = new Date().getTime()
    result = (this.reduce k,v for k,v of @mapResult)
    end = new Date().getTime()
    postMessage "Reduce -> #{end-start}ms /  #{Object.keys(@mapResult).length}</br>"
    result

  f::execute = (data) ->
    this.wrapMap(data)
    do this.wrapReduce
  f

handleExecute = (data) ->
  funs = []
  funs.push(extendFunction(f)) for f in data.funs
  tmp = data.data
  for f in funs
    postMessage "Calling MR Cycle<br/>"
    a = (new f()).execute(tmp)
    tmp = a

  postMessage "Finalizing...<br/>"
  
  postMessage tmp


this.addEventListener "message", (e) ->
  postMessage "Received execute...<br/>"
  data = e.data
  switch data.cmd
    when "execute" then handleExecute(data)
  false

