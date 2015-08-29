React = require 'react'
ReactDOM = require 'react-dom'
ReactBootstrap = require 'react-bootstrap'
Backbone = require 'backbone'
$ = require 'jquery'
_ = require 'lodash'

require 'bootstrap/less/bootstrap.less'
require './app.less'

{pre, h1, div, span, i, input, ul, li, button} = ReactDOM
{Navbar, Button} = ReactBootstrap

trim = (s) ->
  s.replace(/^s+|s+$/g, '')

addCssClass = (props, classNamesToAdd) ->
  if !classNamesToAdd.length
    classNamesToAdd = [classNamesToAdd]
  _.extend {}, props, { className: _.uniq((props.className || "").split(/\s+/).concat(classNamesToAdd)).join(" ") }


ButtonGlyph = React.createClass
  render: ->
    props = addCssClass @props, ["glyphicon", "glyphicon-"+@props.glyph]
    <button {...props}></button>

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
    if trim(@state.description)
      @props.onTaskCreated && @props.onTaskCreated({ description: @state.description })
      @setState({ description: "" })
  render: ->
    <div className="row">
      <div className="col-md-12">
        <input
          ref="description"
          autoFocus={true}
          placeholder="Task description"
          className="col-md-12",
          value={@state.description}
          onChange={@descriptionChanged}
          onKeyDown={@keyDown}
        />
        <Button onClick={@createTask}>Add task</Button>
      </div>
    </div>



BackboneModel = (modelPropName) ->
#   componentDidUpdate: (prevProps, prevState) ->
#     change = _.chain(@state[modelPropName])
#       .pairs()
#       .reject(([key, value]) => prevState[modelPropName][key] == value)
#       .filter(([key, value]) => key of @props[modelPropName].attributes)
#     if change.size().value() > 0
#       @props[modelPropName].set(change.object().value())
  getInitialState: ->
    @props[modelPropName].on 'change sync', (event) =>
      if @isMounted()
        @forceUpdate()
#       change = event.changed
#       change = _.chain(event.changed).pairs().reject(([key, value]) =>
#         event._previousAttributes[key] == value
#       )
#       if change.size().value() > 0
#         @setState pair modelPropName, _.extend(@state[modelPropName], change.object().value())
#     pair modelPropName, @props[modelPropName].attributes

BackboneCollection = (modelPropName) ->
  getInitialState: ->
    @props[modelPropName].on 'add remove reset sort', (event) =>
      if @isMounted()
        @forceUpdate()


l = console.log.bind(console)

Task = React.createClass
  mixins: [ BackboneModel('task') ]
  getInitialState: ->
    edited: false
  remove: ->
    @props.task.destroy();
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
    @props.task.set('description', @state.edited.description);
    @props.task.save();
    @setState { edited: false }
  cancel: ->
    @setState { edited: false }
  render: ->
    <li>
      {if @state.edited
        <span>
          {if @props.task.get('important') then "[*]"}
          <ButtonGlyph onClick={@save} glyph='ok' />
          <ButtonGlyph onClick={@cancel} glyph='remove' />
          <input ref="description" value={@state.edited.description} onChange={@descriptionChanged} onKeyDown={@keyDown} />
        </span>
      else
        <span>
          {if @props.task.get('important') then "[*]"}
          <ButtonGlyph onClick={@remove} glyph='trash' />
          <ButtonGlyph onClick={@edit} glyph='pencil' />
          <span>{@props.task.get('description')}</span>
        </span>
      }
    </li>

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
    <div className="panel">
      <div className="row">
        <div className="col-md-12">
          <ul>
            {for task in @props.tasks.models
              <Task key={task.id} task={task} onRemove={@removedTask}, onEdited={@editedTask} />
            }
          </ul>
        </div>
      </div>
      <TaskCreator ref="taskCreator" onTaskCreated={@appendTask} />
    </div>



App = React.createClass
  getInitialState: ->
    { unrelated: true }
  deleteAll: ->
    $.post('http://localhost:3000/clear')
    @props.model.reset();
  render: ->
    <div>
      <Navbar>
        <h1>{"Worklog" + (if !@props.me then "" else " : " + @props.me.get('name').givenName + " " + @props.me.get('name').familyName)}
          <div className='pull-right'>
            <Button onClick={@deleteAll}>Delete all</Button>
            <Button href="http://localhost:3000/auth/google">Log in (via Google)</Button>
            <Button href="http://localhost:3000/auth/google/logout">Log out</Button>
          </div>
        </h1>
      </Navbar>
      <div className="container">
        <TaskList tasks={@props.model} />
      </div>
    </div>


TaskModel = Backbone.Model.extend
  urlRoot: 'http://localhost:3000/task'
  idAttribute: '_id'
  description: ""
  important: false
#   initialize: ->
#     @on 'change', ->
#       @save()



TasksCollection = Backbone.Collection.extend
  model: TaskModel
  url: 'http://localhost:3000/task'
  initialize: ->
    @on 'add', (model) ->
      model.save()


User = Backbone.Model.extend
  urlRoot: 'http://localhost:3000/user'
  idAttribute: '_id'



tasksCollection = new TasksCollection []

# CORS
default_Backbone_Sync = Backbone.sync;
Backbone.sync = (method, model, options) ->
    options ||= {}
    if !options.crossDomain
      options.crossDomain = true;
    if !options.xhrFields
      options.xhrFields = {withCredentials:true}
    default_Backbone_Sync method, model, options

$(document)
  .ajaxError (event, jqXHR, settings, thrownError) ->
    if jqXHR.status == 401
      window.location.href = 'http://localhost:3000/auth/google';

  .ready ->
    me = new User({ _id: 'me' })
    me.fetch()
      .fail ->
        me = null
      .always ->
        tasksCollection.fetch(reset: true).always ->
          React.render <App model={tasksCollection ? []} me={me} />, document.body
