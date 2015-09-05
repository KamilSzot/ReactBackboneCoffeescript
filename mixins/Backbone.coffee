
module.exports =
  BackboneModel: (modelPropName) ->
    copyDateToState: (event) ->
      @setState 
        "#{modelPropName}": @props[modelPropName].attributes
      
    componentWillMount: ->
      @props[modelPropName].on 'change sync', @copyDateToState
          
    componentWillUnmount: ->
      @props[modelPropName].off 'change sync', @copyDateToState
          
    getInitialState: ->
      "#{modelPropName}":
        @props[modelPropName].attributes


  BackboneCollection: (collectionPropName) ->
    copyDateToState: (event) ->
      @setState 
        "#{collectionPropName}": @props[collectionPropName].models
    
    componentWillMount : ->
      @props[collectionPropName].on 'add remove reset sort', @copyDateToState

    componentWillUnmount : ->
      @props[collectionPropName].off 'add remove reset sort', @copyDateToState
            
    getInitialState: ->
      "#{collectionPropName}":
        @props[collectionPropName].models
