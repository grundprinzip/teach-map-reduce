class MapReduceManager

  constructor: ->
    @callers = []
    
    # Editor Sessions
    @mapper_sessions = []
    @reducer_sessions = []

  addCycle: (fun) ->
    # fun is a prototype so add the to important methods
    fun::mapResult = {}
    fun::reduceResult = []

    # Called by the map function
    fun::emit = (key, value)->
      if !@mapResult[key]
        @mapResult[key] = []

      @mapResult[key].push value

    fun::wrapMap = (data) ->
      this.map l for l in data

    fun::wrapReduce = ->
      this.reduce k,v for k,v of @mapResult

    fun::execute = (data) ->
      this.wrapMap(data)
      do this.wrapReduce

    @callers.push fun

  addSession: (ms, rs) ->
    @mapper_sessions.push ms
    @reducer_sessions.push rs

  execute: (dataset)->
    @callers = []

    mapper_data = (do session.getValue for session in @mapper_sessions)
    reducer_data = (do session.getValue for session in @reducer_sessions)

    # Add A new MR for each cycle to the global list
    this.addCycle new Function(m1 + reducer_data[i]) for m1,i in mapper_data

    callers = @callers
    # Now all the functions are added
    $.get("data/#{dataset}", (data) ->
      data = $.parseJSON(data)
      tmp = data
      for c in callers
        a = (new c()).execute(tmp)
        tmp = a

      $("#result").html("")
      result = new jsoneditor.JSONEditor $("#result")[0], mode: "view", tmp
      )


window.mr = new MapReduceManager()

window.cycleCount = 0

window.init = ->
  $.get "data/one.json", (data) ->
    data = $.parseJSON(data)
    new jsoneditor.JSONEditor $("#tweet_example")[0], mode: "view", data


  $("#query").click ->
    mr.execute $("select[name='dataset']").val()
    false

  $("#addCycle").click (e) ->
    data = """
    <hr />
    <h3>Cycle #{window.cycleCount + 1}</h3>
    <p>Map</p>
    <pre id="cycle_#{window.cycleCount}_map" class="editor">
    this.map = function(item) {
      this.emit(/*item.text*/);
    };
    </pre>
    <p>Reduce</p>
    <pre id="cycle_#{window.cycleCount}_reduce" class="editor">
    this.reduce = function(key, values) {
      return /* anything */;
    };
    </pre>
    """
    $(".cycles .inner").append(data);
    
    # Initialize the editor for each cycle
    editor_map = ace.edit("cycle_#{window.cycleCount}_map")
    editor_map.setTheme("ace/theme/chrome")
    editor_map.getSession().setMode("ace/mode/javascript")

    editor_reduce = ace.edit("cycle_#{window.cycleCount}_reduce")
    editor_reduce.setTheme("ace/theme/chrome")
    editor_reduce.getSession().setMode("ace/mode/javascript")

    window.cycleCount += 1
    mr.addSession editor_map.getSession(), editor_reduce.getSession()

    false

  $("#addCycle").click()