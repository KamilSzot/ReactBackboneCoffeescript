React = require 'react'

addCssClass = (props, classNamesToAdd) ->
  if !classNamesToAdd.length
    classNamesToAdd = [classNamesToAdd]
  _.extend {}, props, { className: _.uniq((props.className || "").split(/\s+/).concat(classNamesToAdd)).join(" ") }


module.exports = ButtonGlyph = React.createClass
  render: ->
    props = addCssClass @props, ["glyphicon", "glyphicon-"+@props.glyph]
    <button {...props}></button>
