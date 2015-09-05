
React = require 'react'
# ReactDOM = require 'react-dom'
Backbone = require 'backbone'
$ = require 'jquery'
_ = require 'lodash'

require './app.less'

App = require './components/App'




l = console.log.bind(console)




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
