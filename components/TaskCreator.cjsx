React = require 'react'
{Button} = require 'react-bootstrap'

trim = (s) ->
  s.replace(/^s+|s+$/g, '')


module.exports = TaskCreator = React.createClass
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
