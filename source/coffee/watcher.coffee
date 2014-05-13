#  _   _ _       __          __   _       _               
# | \ | (_)      \ \        / /  | |     | |              
# |  \| |_ _ __ __\ \  /\  / /_ _| |_ ___| |__   ___ _ __ 
# | . ` | | '__/ _ \ \/  \/ / _` | __/ __| '_ \ / _ \ '__|
# | |\  | | | | (_) \  /\  / (_| | || (__| | | |  __/ |   
# |_| \_|_|_|  \___(_)/  \/ \__,_|\__\___|_| |_|\___|_|   
                                                      

Niro.Watcher = Niro.Class.extend 'Watcher', ->


   @constructor = (@container) ->

      # add niro observed property
      Object.defineProperty @container, 'x-niro-observed', enumerable: no, value: yes 

      # collection of watched items
      @watching = []

      # collection of observed items
      @observing = []

      # handlers store 
      @handlers = {}


   # register event listeners
   @on = (event, deep, handler = deep) ->

      # deep defaults to no 
      deep = no if _.isFunction(deep) 

      # save event handler
      (@handlers[event] ?= []).push {handler, deep}

      # get property path
      path = event.substr(0, event.lastIndexOf(':'))

      # get path details and values
      sections = _.getContainerAndProperty(@container, path)


      if not deep 
         @observeProperty(sections)
      else 
         @observeObject(sections)


   # observe a single property for changes
   @observeProperty = (options) ->
      # save path reference
      { path } = options

      # quit if already observed
      return if path in @observing


      # get current value
      value = options.property

      # create observer 
      Object.defineProperty options.container, options.propertyPath, 
         get: -> value
         set: (newValue) =>
            _.delay 0, => @dispatch("#{path}:change")
            return value = newValue
      
      # add path to observing list
      @observing.push path


   # handle object keys changed 
   @keysChanged = (options, keys, newKeys) ->
      deleted = keys.filter (item) -> item not in newKeys
      added   = newKeys.filter (item) -> item not in keys 
      called = no
      for item in added 
         event = _.joinPath(options.path, item) + ':added'
         called = @dispatch(event)

      for item in deleted
         event = _.joinPath(options.path, item) + ':deleted'
         @dispatch(event)

      if called
         log 'need'


   # observe a object for new or deleted properties
   @observeObject = (options) ->
      keys = Object.keys(options.property)
      _.interval 500, =>
         newKeys = Object.keys(options.property)
         unless "#{keys}" is "#{newKeys}"
            @keysChanged(options, keys, newKeys)
            keys = newKeys

   # dispatch property change events
   @dispatch = (event, deep = no) ->
      # get relevent properties
      parts = event.split(':')
      event = do parts.pop
      path = parts.join(':')
      pathParts = _.splitPath(path)
      called = no

      while pathParts.length
         # join path and event
         _event = _.joinPath(pathParts) + ":#{event}"


         # get event handlers
         handlers = @handlers[_event]

         # if handlers then loop handlers
         if handlers
            for handler in handlers 

               # if deep and handler is deep or not deep at all, call handler
               if deep and handler.deep or not deep 
                  called = yes 
                  handler.handler(_event)


         if deep and event isnt 'change'
            _called = @dispatch(_.joinPath(pathParts) + ':change', yes)
            if _called then called = _called

         # pop last path item 
         pathParts.pop()         

         # after first run, going deep
         deep = yes 


      return called










t = {
   data: name: 'connor'
}



watcher = new Niro.Watcher(t)

watcher.on 'data.name:change', ->
   log 'name changed'




watcher.on 'data:change', yes, ->
   log 'going deep'


watcher.on 'data:change', ->
   log 'shallow'



