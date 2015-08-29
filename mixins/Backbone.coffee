
module.exports =
  BackboneModel: (modelPropName) ->
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

  BackboneCollection: (modelPropName) ->
    getInitialState: ->
      @props[modelPropName].on 'add remove reset sort', (event) =>
        if @isMounted()
          @forceUpdate()
