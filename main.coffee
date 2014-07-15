{h1, div, span, i, input, ul, li, button} = React.DOM
{Navbar, Button} = ReactBootstrap



addCssClass = (props, classNamesToAdd) ->
  if !classNamesToAdd.length 
    classNamesToAdd = [classNamesToAdd]
  props.className = _.uniq((props.className || "").split(/\s+/).concat(classNamesToAdd)).join(" ")

ButtonGlyph = React.createClass
  render: ->
    addCssClass @props, ["glyphicon", "glyphicon-"+@props.glyph]
    button @props

      
TaskCreator = React.createClass
  getInitialState: ->
    description: ""
  focus: ->
    @refs.description.getDOMNode().focus()  
  keyDown: (event) ->
    if event.keyCode == 13
      @createTask()
  descriptionChanged: (event) ->
    @setState({ description: event.target.value })
  createTask: ->
    if @state.description.trim() 
      @props.onTaskCreated && @props.onTaskCreated({ description: @state.description })
      @setState({ description: "" })
  render: ->
    div { className: "row" },
      div { className: "col-md-12" }, 
        input { 
          ref: "description", 
          autoFocus: true, 
          placeholder: "Task description", 
          className: "col-md-12", 
          value: @state.description 
          onChange: @descriptionChanged, 
          onKeyDown: @keyDown
        },
        Button {
          onClick: @createTask
        }, "Add task"
    
BackboneModel = (modelPropName) ->
  { 
    componentWillUpdate: (nextProps, nextState) ->
      change = _.chain(nextState[modelPropName])
        .pairs()
        .reject(([key, value]) => @state[modelPropName][key] == value)
        .filter(([key, value]) => key of @props[modelPropName].attributes)
      if change.size().value() > 0
        @props[modelPropName].set(change.object().value())
    getInitialState: ->
      @props[modelPropName].on 'change', (event) =>
        change = event.changed
        change = _.chain(event.changed).pairs().reject(([key, value]) =>
          event._previousAttributes[key] == value
        )
        if change.size().value() > 0
#           console.log(change.object().value());
          @setState change.object().value()
      
      state = {}
      state[modelPropName] = @props[modelPropName].attributes
      state
  }
        
BackboneCollection = (modelPropName) ->
  { 
#     componentWillUpdate: (nextProps, nextState) ->
#       change = _.chain(nextState)
#         .pairs()
#         .reject(([key, value]) => @state[key] == value)
#       if change.size().value() > 0
#         @props[modelPropName].set(change.object().value())
    getInitialState: ->
      @props[modelPropName].on 'add', (event) =>
        @setState @state
      @props[modelPropName].on 'remove', (event) =>
#         console.log event
        @setState @state
       
      state = {}
      state[modelPropName] = @props[modelPropName].models
      state
  }
        
l = console.log.bind(console)

Task = React.createClass
  mixins: [ BackboneModel('task') ]
  getInitialState: ->
    edited: false
  remove: ->
    @props.onRemove && @props.onRemove(@props.task)
  edit: ->
    @setState { edited: _.clone(@props.task.attributes) }, => @refs.description.getDOMNode().focus()
    @props.onEdit && @props.onEdit(@props.task)
   
  descriptionChanged: (event) ->
    @setState { edited: _.extend(@state.edited, { description: event.target.value }) }
  keyDown: (event) ->
    if event.keyCode == 13
      @save()
    if event.keyCode == 27
      @cancel()
  save: ->
    @props.onEdited && @props.onEdited(@props.task, @state.edited)
    @setState _.extend { task: @state.edited, edited: false }
  cancel: ->
    @setState { edited: false }
  render: ->
#     console.log @state
    li {}, 
      if @state.edited
        span {},
          ButtonGlyph { onClick: @save, glyph: 'ok'}
          ButtonGlyph { onClick: @cancel, glyph: 'remove' }
          input { ref: "description", value: @state.edited.description, onChange: @descriptionChanged, onKeyDown: @keyDown }
      else
        span {},
          ButtonGlyph { onClick: @remove, glyph: 'trash' }
          ButtonGlyph { onClick: @edit, glyph: 'pencil' }
          span {}, @state.task.description  
   
TaskList = React.createClass
  mixins: [ BackboneCollection('tasks') ]      
  appendTask: (taskData) ->
    @props.tasks.add(new @props.tasks.model(taskData))
    @refs.taskCreator.focus()
  removedTask: (taskData) ->
    @props.tasks.remove(taskData)
    @refs.taskCreator.focus()
  editedTask: (task, newTaskData) ->
    console.log [task, newTaskData]
  render: ->
    self = this
    div { className: "panel" },
      div { className: "row" },
        div { className: "col-md-12" },  
          ul { }, 
            for task in @state.tasks
              Task { task: task, onRemove: @removedTask, onEdited: @editedTask }
      TaskCreator {
        ref: "taskCreator",
        onTaskCreated: @appendTask
      }


        
App = React.createClass
  getInitialState: ->
    { unrelated: true }
  render: ->
    div {}, 
      Navbar {}, [
        h1 {}, "Worklog"
      ]
      div { className: "container" },
        TaskList { tasks: @props.model }
#         div { }, ":" + @state.unrelated + ":" + @state.text
#       button { onClick: @props.model.fetch.bind(@props.model, undefined, undefined) }, "refresh"
      

# models = {}
# 
# models.Task = Backbone.Model.extend {
#   defaults: ->
#     description: "[empty]"
# }
# 
# models.Tasks = Backbone.Collection.extend {
#   model: models.Task,
#   url: 'http://localhost:8081/backend.php?all'
# }
# 
# 
# tasksAll = new models.Tasks();
# tasksAll.url = 'http://localhost:8081/backend.php?all'

TaskModel = Backbone.Model.extend 
  urlRoot: 'http://localhost:8081/task'
  description: ""
  initialize: -> 
    @on 'change', -> 
      @save()


      

TasksCollection = Backbone.Collection.extend
  model: TaskModel
  url: 'http://localhost:8081/task' 
    

tasksCollection = new TasksCollection [ 
]

tasksCollection.fetch().done ->
  tasksCollection.models[0].set({ description: "TesT" });
#   tasksCollection.models[0].save();



React.renderComponent App( model: tasksCollection ), document.body 

# FooterModel = Backbone.Model.extend { text: "" }
# footer = new FooterModel({});
# footer.url = 'http://localhost:8081/backend.php?footer'
# footer.fetch
#   success: ->

# tasksAll.fetch 
#   success: -> { model: tasksAll }
#     React.renderComponent App( model: footer ), document.body 

# setInterval(footer.fetch.bind(footer), 500)