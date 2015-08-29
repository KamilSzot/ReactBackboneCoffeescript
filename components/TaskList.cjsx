React = require 'react'
{ BackboneCollection } = require '../mixins/Backbone'

Task = require './Task'
TaskCreator = require './TaskCreator'


module.exports = TaskList = React.createClass
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
