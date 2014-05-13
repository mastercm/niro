#  _   _ _            _____                                      
# | \ | (_)          / ____|                                     
# |  \| |_ _ __ ___ | |     ___  _ __ ___  _ __ ___   ___  _ __  
# | . ` | | '__/ _ \| |    / _ \| '_ ` _ \| '_ ` _ \ / _ \| '_ \ 
# | |\  | | | | (_) | |___| (_) | | | | | | | | | | | (_) | | | |
# |_| \_|_|_|  \___(_)_____\___/|_| |_| |_|_| |_| |_|\___/|_| |_|

Niro.Common = do (exports = {}, global = window) ->

   # global variables
   global.log = console.log.bind(console)
   global.dir = console.dir.bind(console)

   # local variables 
   slice = [].slice  

   # convert array-like objects to array 
   exports.toArray = (value) ->
      slice.call value 

   # empty dummy function
   exports.noop = ->

   # check if value is a function
   exports.isFunction = (value) ->
      typeof value is 'function'

   # check if value is array 
   exports.isArray = (value) ->
      value instanceof Array 

   # check if value is object 
   exports.isObject = (value) ->
      value isnt null and typeof value is 'object'

   # check if value is string
   exports.isString = (value) ->
      typeof value is 'string'

   # check if value is number
   exports.isNumber = (value) ->
      typeof value is 'number'

   # check if value is regex
   exports.isRegex = (value) ->
      value instanceof RegExp

   # check if value is node 
   exports.isNode = (value) ->
      value instanceof Node 

   # check if value is a Date
   exports.isDate = (value) ->
      value instanceof Date

   # check if value is Boolean
   exports.isBoolean = (value) ->
      typeof value is 'boolean'

   # try to confirm if object was manually created 
   exports.isCustomObject = (value) ->
      @isObject(value) and not @isRegex(value) and 
      not @isDate(value) and not @isNode(value)

   # check if value is a dictionary object
   exports.isDictionary = (value) ->
      @isObject(value) and not @isArray(value) and @isCustomObject(value)

   # check if value is a circular object
   exports.isCircular = (value) ->
      try 
         JSON.stringify(value)
         return false
      catch error 
         return error.stack.indexOf('circular') isnt -1

   # escape special regex characters
   exports.escapeRegex = (string) ->
      string.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1")

   # loop through an array or array-like object
   exports.forIn = (array, handler, context) ->
      
      # ensure `value` is an Array
      unless @isArray(array)
         throw Error('forIn expected first argument to be an Array, type was ' + typeof array)

      # ensure `handler` is a Function 
      unless @isFunction(handler)
         throw Error('forIn expected second argument to be a Functon, type was ' + typeof handler)

      # ensure `context` is a object (if provided)
      if context and not @isObject(context)
         throw Error('forIn expected third argument (context) to be a Object if it was provided, type was', typeof context)

      # execute forIn operation
      handler.call(context, value, index, array) for value, index in array

      # return array passed
      return array

   # extend destination object with mulitple sources
   exports.extend = (destination, sources...) ->

      # ensture `destination` is object
      unless @isObject(destination) or @isFunction(destination)
         throw Error 'extend expected first arguments to be an Object or FunctionFunctino, type was ' + typeof destination

      # loop through sources
      for source, index in sources

         unless @isObject(source) or @isFunction(source)
            continue

         # loop through source properties
         for own property, value of source

            # if values are objects, re-extend
            if @isDictionary(value) and @isObject(position = destination[property])
               @extend(position, value)

            # else assign value
            else 
               destination[property] = value


      # return modified destination
      return destination

   # make a deep copy of an object
   exports.clone = (object) ->

      # return object if it isnt a Object
      return object if not object or not @isObject(object) or @isRegex(object)

      # clone date objects
      if @isDate(object)
         return new Date object.getTime()


      # create new instance
      instance = new object.constructor;

      # clone for each property
      for own property, value of object 
         instance[property] = @clone(value)

      # return new clone
      return instance

   # search through every single value within a object
   exports.search = (object, handler, startPath) ->

      # ensure `object` is a Object
      unless @isObject(object)
         throw Error "search expected first argument (object) to be a Object, type was #{typeof object}"

      # ensure `handler` is a Function
      unless @isFunction(handler)
         throw Error "search expected second argument (handler) to be a Fucntion, type was #{typeof handler}"
      
      # ensure `startPath` is string (if provided)
      if startPath and not @isString(startPath)
         throw Error "search expected third argument (startPath) to be a String if provided, type was #{typeof startPath}"


      # loop object properties
      for own property, value of object 

         # call handler
         unless property is 'length'
            handler(value, property, object)

         # if is object then continue search
         if @isArray(value) or @isObject(value) and not @isCircular(value)
            @search(value, handler)

   # split string path into parts
   exports.splitPath = (path) ->
      path.split(/\[|\]|\./).filter(Boolean)

   # join path paths into string path
   exports.joinPath = (parts) ->

      # allow singular argument or splat-like
      parts = if @isArray(parts) then parts else @toArray arguments

      # path result
      path = ''

      # loop parts and add to path
      for part in parts 
         unless isNaN(part)
            part = "[#{part}]"
         else if path.length > 0
            part = ".#{part}"

         path += part



      return path;

   # get value in object by string path
   exports.getByPath = (object, path) ->

      # ensure `object` is Object
      unless @isObject(object)
         throw Error "getByPath expected first argument (object) to be a Object, type was #{typeof object}"

      # return object if path not provided or not value
      return object unless path 

      # split path into parts 
      parts = @splitPath(path)
      last  = parts.pop()

      # dig through object
      object = object[part] or {} for part in parts

      # return last item
      return object[last]

   # set value in object by string path
   exports.setByPath = (object, path, value) ->

      # ensure `object` is Object
      unless @isObject(object)
         throw Error "setByPath expected first argument (object) to be a Object, type was #{typeof object}"

      # return value and do nothing if path not present or invalid
      return value unless path

      # split path into parts 
      parts = @splitPath(path)
      last  = parts.pop()

      # dig through object
      object = object[part] ?= {} for part in parts

      # return last item
      return object[last] = value 

   # get container and property values from path
   exports.getContainerAndProperty = (object, path) ->

      # split path into parts
      parts = @splitPath(path)

      # get property section of path
      propertyPath = do parts.pop

      # get container section of path
      containerPath = @joinPath(parts)

      # get container value
      container = @getByPath(object, containerPath)

      # get property value 
      property = @getByPath(container, propertyPath)

      # return all results
      return {container, property, containerPath, propertyPath, path}


   # Timer's section
   # setTimeout alias
   exports.delay = (ms, handler) ->
      global.setTimeout(handler, ms)

   # setInterval alias
   exports.interval = (ms, handler) ->
      global.setInterval(handler, ms)

   # clear timeout and intervals
   exports.clearDelay = global.clearTimeout.bind(global)
   exports.clearInterval = global.clearInterval.bind(global)



   # Number prototype methods

   # convert number to ordinal string
   Number::toOrdinalString = ->

      # ordinal characters
      chars = ['st', 'nd', 'rd']

      # get string value
      value = "" + @valueOf()

      # get extension index
      index = value.charAt(value.length - 1) - 1

      # return value with correct extension
      return value + (chars[index] or 'th')


   # String prototype methods

   # remove item from string
   String::remove = (item, global) ->
      regex = new RegExp _.escapeRegex(item), (global and 'g')
      @valueOf().replace regex, ''

   # escape certain characters in a string
   String::escape = (characters...) ->

      # get string value
      string = @valueOf()

      # loop through characters
      for character in characters 

         # create character regex
         regex = new RegExp _.escapeRegex(character), 'g'

         # replace character with escaped character
         string = string.replace regex, '\\' + character

      return string



   # export utilities
   return global._ = exports 