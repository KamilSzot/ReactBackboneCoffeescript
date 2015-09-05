React = require 'react'
React.addons = 
  update: require 'react-addons-update'
  
{ BackboneModel } = require '../mixins/Backbone'


ButtonGlyph = require './ButtonGlyph'

module.exports = Task = React.createClass
  mixins: [ BackboneModel('task') ]
  getInitialState: ->
    edited: false
  remove: ->
    @props.task.destroy();
    @props.onRemove && @props.onRemove(@props.task)
  edit: ->
    @setState { edited: _.clone(@props.task.attributes) }, => @refs.description.focus()
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
    @props.task.save(@state.edited);
    @setState { edited: false }
  cancel: ->
    @setState { edited: false }
  render: ->
    <li {...@props.drag} style={@props.style} className={@props.className}>
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
          <span>{@state.task.description}</span>
        </span>
      }
    </li>
