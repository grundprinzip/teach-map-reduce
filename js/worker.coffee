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
    for l in data
      this.map l 

  f::wrapReduce = ->
    this.reduce k,v for k,v of @mapResult

  f::execute = (data) ->
    this.wrapMap(data)
    do this.wrapReduce
  f

handleExecute = (data) ->
  funs = []
  funs.push(extendFunction(f)) for f in data.funs
  tmp = data.data
  for f in funs
    a = (new f()).execute(tmp)
    tmp = a

  postMessage tmp


this.addEventListener "message", (e) ->
  data = e.data
  switch data.cmd
    when "execute" then handleExecute(data)
  false

