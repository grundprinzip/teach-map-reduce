$ = 
  trim: (data) ->
    do data.trim

STOP_WORDS_EN = ['a','able','about','across','after','all','almost','also','am','among','an','and','any','are','as','at','be','because','been','but','by','can','cannot','could','dear','did','do','does','either','else','ever','every','for','from','get','got','had','has','have','he','her','hers','him','his','how','however','i','if','in','into','is','it','its','just','least','let','like','likely','may','me','might','most','must','my','neither','no','nor','not','of','off','often','on','only','or','other','our','own','rather','said','say','says','she','should','since','so','some','than','that','the','their','them','then','there','these','they','this','tis','to','too','twas','us','wants','was','we','were','what','when','where','which','while','who','whom','why','will','with','would','yet','you','your'];

funs = []
self = this

console =
  log: (data) ->
    postMessage console: data

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

