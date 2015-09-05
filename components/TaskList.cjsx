React = require 'react'
{ BackboneCollection } = require '../mixins/Backbone'

Task = require './Task'
TaskCreator = require './TaskCreator'
_ = require 'lodash'


module.exports = TaskList = React.createClass
  mixins: [ BackboneCollection('tasks') ]
  appendTask: (taskData) ->
    new @props.tasks.model(taskData).save({}, { success: (task) => @props.tasks.add(task) })
    
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
            {for task in @state.tasks
              <Task key={task.id} task={task} onRemove={@removedTask}, onEdited={@editedTask} />
            }
          </ul>
        </div>
      </div>
      <TaskCreator ref="taskCreator" onTaskCreated={@appendTask} />
    </div>
