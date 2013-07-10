class MapReduceManager

  constructor: ->
    @callers = []
    
    # Editor Sessions
    @mapper_sessions = []
    @reducer_sessions = []

  addSession: (ms, rs) ->
    @mapper_sessions.push ms
    @reducer_sessions.push rs


window.mr = new Worker("js/worker.js")
window.storage = new MapReduceManager()

# Debug only
window.mr.onmessage = (e) ->
  if typeof e.data is "object"
    if e.data.console
      console.log e.data.console
    else 
      $("#result").html("")
      result = new jsoneditor.JSONEditor $("#result")[0], mode: "view", e.data    
  else
    $("#msg").append(e.data)    


window.cycleCount = 0

window.init = ->
  $.get "data/one.json", (data) ->
    if typeof(data) != "object"
      data = $.parseJSON(data)

    new jsoneditor.JSONEditor $("#tweet_example")[0], mode: "view", data

  $("#query").click ->
    $("#msg").html("")
    # Collect all mappers and reducers
    list = (window.storage.mapper_sessions[idx].getValue() + window.storage.reducer_sessions[idx].getValue() for idx in [0..window.cycleCount-1])
    dataset = $("select[name='dataset']").val()
    $.get "data/#{dataset}", (data) ->
      if typeof(data) != "object"
        data = $.parseJSON(data)
      mr.postMessage 
        cmd: "execute"
        data: data
        funs: list
    false


  $("#clear").click ->
    window.mr = new Worker("js/worker.js")
    window.cycleCount = 0
    $(".cycles .inner").html("")
    $("#result").html("")
    do $("#addCycle").click
    false

  $("#addCycle").click (e) ->
    data = """
    <hr />
    <h3>Cycle #{window.cycleCount + 1}</h3>
    <p>Map</p>
    <pre id="cycle_#{window.cycleCount}_map" class="editor">
    this.map = function(item) {
      this.emit(/*key, value*/);
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
    window.storage.addSession editor_map.getSession(), editor_reduce.getSession()
    false

  $("#addCycle").click()