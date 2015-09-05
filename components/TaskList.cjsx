React = require 'react'
{ BackboneCollection } = require '../mixins/Backbone'

Task = require './Task'
TaskCreator = require './TaskCreator'

_ = require 'lodash'
$ = require 'jquery'

require './TaskList.less'


module.exports = TaskList = React.createClass
  mixins: [ BackboneCollection('tasks') ]
  getInitialState: ->
    {}
  appendTask: (taskData) ->
    new @props.tasks.model(taskData).save({}, { success: (task) => @props.tasks.add(task) })
    
    @refs.taskCreator.focus()
  removedTask: (taskData) ->
    @props.tasks.remove(taskData)
    @refs.taskCreator.focus()
  editedTask: (task, newTaskData) ->
    console.log [task, newTaskData]
  startDragging: (idx) ->
    (e) =>
      e.dataTransfer.setDragImage(new Image(), 0, 0)  
      e.dataTransfer.setData('Text', idx)
      e.dataTransfer.effectAllowed = "move"
      @setState { dragging: idx }
  dragOver: (idx) ->
    (e) =>
      if @state.dragging != idx
        offset = if @state.dragging < idx then 1 else 0
        el = @state.tasks.splice(@state.dragging, 1)[0]
        
        if e.clientY - $(e.currentTarget).offset().top > $(e.currentTarget).height() / 2
          @state.tasks.splice(idx + 1 - offset, 0, el)
          @setState { tasks: @state.tasks, dragging: idx + 1 - offset }
        else 
          @state.tasks.splice(idx - offset, 0, el)
          @setState { tasks: @state.tasks, dragging: idx - offset }

      e.dataTransfer.dropEffect = 'move';
      e.preventDefault()
      undefined
  
  render: ->
    <div className="panel">
      <div className="row">
        <div className="col-md-12">
          <ul>
            {for task, idx in @state.tasks
              <Task key={task.id}
                task={task}
                style={{ 'background': if idx == @state.dragging then 'lime' }} 
                onRemove={@removedTask} 
                onEdited={@editedTask} 
                drag={ draggable: "true", onDragStart: @startDragging(idx), onDragOver: @dragOver(idx), onDragEnd: (e) => @setState { dragging: null } } 
              />
            }
          </ul>
        </div>
      </div>
      <TaskCreator ref="taskCreator" onTaskCreated={@appendTask} />
    </div>
