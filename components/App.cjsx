React = require 'react'
{Navbar, Button} = require 'react-bootstrap'

TaskList = require './TaskList'

module.exports = App = React.createClass
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
