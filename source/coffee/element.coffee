#  _   _ _            ______ _                           _   
# | \ | (_)          |  ____| |                         | |  
# |  \| |_ _ __ ___  | |__  | | ___ _ __ ___   ___ _ __ | |_ 
# | . ` | | '__/ _ \ |  __| | |/ _ \ '_ ` _ \ / _ \ '_ \| __|
# | |\  | | | | (_) || |____| |  __/ | | | | |  __/ | | | |_ 
# |_| \_|_|_|  \___(_)______|_|\___|_| |_| |_|\___|_| |_|\__|

Niro.Element = Niro.Class.extend 'Element', ->

   # store element data
   data = id: 1


   # set data id on store
   setStoreId = (node) ->
      data[ value = data.id++ ] = {}
      Object.defineProperty node, 'niroStoreId', {writable: no, enumerable: no, value}
      return value 


   # implement array values
   @implement Array

   # default constructor
   @context = document

   # default options
   @instanceOptions = types: [1, 9]

   # constructor for Niro.Element
   @constructor = (selectors...) ->
      Object.defineProperty this, 'length', enumerable: no, writable: yes, value: 0
      @concatValues(selectors)


   # concat a variety of values into the instance
   @concatValues = (values...) ->

      # resulting nodes
      result = []

      # search through values 
      _.search values, (value) =>
         
         # check if value is string
         if _.isString(value)

            # value is unparsed HTML
            if value.trim().indexOf('#>') is 0
               return result.push.apply(result, @parseHTML value.remove('#>'))

            try 
               nodes = @context.querySelectorAll(value)
               return result.push.apply(result, nodes)

         # push nodes into collection
         if _.isNode(value)
            result.push(value)

      # filter allowed nodes and ensure no duplicates, then push to instance
      @push.apply this, result.filter (node, index) => 
         (node.nodeType in @instanceOptions.types) and result.indexOf(node) is index;


      return this 


   # parse string into HTML content
   @parseHTML = (string) ->

      # create temp element
      temp = document.createElement('div')

      # set inner html
      temp.innerHTML = string

      # return child nodes
      return temp.childNodes


   # configure instance options
   @options = (options) ->
      @instanceOptions = _.extend({}, @instanceOptions, options)
      return this


   # run operations on each element in the set
   @operate = (options, handler) ->
      
      # make options optional
      if _.isFunction(options)
         handler = options
         options = @instanceOptions
      else 
         # extend options with default instance options
         options = _.extend({}, @instanceOptions, options or {})

      # results store
      results = []

      # loop through node collection
      for node, index in this 

         # check if string is property location
         if _.isString(handler)
            result = node[handler]

         # else handler will handle 
         else if _.isFunction(handler)
            result = handler(node, index, this)

         # add result to results 
         if _.isObject(result) and result.length 
            _.search result, (value) -> results.push(value)
         else 
            results.push result


      # send new Niro.Element instance back
      if options.renew 
         return $().options(options).concatValues results.filter (node) -> 
            node.nodeType in options.types

      # send raw response back
      if options.send 
         return if results.length is 1 then results[0] else results


      # return current instance as default
      return this 
            

   # get all children elements
   @children = (options = {}) ->
      options.renew ?= yes
      @operate options, 'childNodes'
 

   # manage class operations class for each element
   classHandler = (property, classes..., options = {}) ->

      # make sure options ins't mistaken for a class
      if _.isString(options)
         classes.push(options)
         options = {}

      @operate options, (node) ->
         node.classList[property](classes...)


   # toggle classes for each element
   @toggleClass = ->
      (args = _.toArray(arguments)).unshift('toggle')
      classHandler.apply(this, args)


   # add classes to each element in the collection
   @addClass = ->
      (args = _.toArray(arguments)).unshift('add')
      classHandler.apply(this, args)


   # remove classes from each element in the collection
   @removeClass = ->
      (args = _.toArray(arguments)).unshift('remove')
      classHandler.apply(this, args)


   # get and set element properties
   @prop = (property, value, options = value) ->

      # getting or setting
      setting = _.isString(value)

      # setting options defaults
      options = {} unless _.isObject(options)

      options.send ?= not setting

      @operate options, (node) ->
         if setting then node[property] = value else node[property]


   # get and set element text content 
   @text = (value, options) ->
      @prop('textContent', value, options)


   # get and set element html content
   @html = (value, options) ->
      @prop('innerHTML', value, options)


   # get and set element attributes
   @attr = (property, value, options = value) ->

      # getting or setting
      setting = _.isString(value)

      # setting options defaults
      options = {} unless _.isObject(options)

      options.send ?= not setting

      @operate options, (node) ->
         if setting then node.setAttribute(property, value) else node.getAttribute(property)


   # remove all elements
   @remove = (options = {}) ->
      @operate options, (node) ->
         node.parentNode?.removeChild(node)
         return node 


   # clone all elements
   @clone = (deep, options = {}) ->
      deep ?= yes
      if _.isObject(deep)
         options = deep

      options.renew ?= yes 
      @operate options, (node) ->
         node.cloneNode(deep)


   # handle appendTo, insertAfter, insertBefore operations
   positionHandler = (position, nodes..., options) ->
      if options and not _.isDictionary(options)
         nodes.push(options)
         options = {}

      # compile nodes
      nodes = $(nodes)

      @operate options, (element) ->
         originalUsed = no

         _.search nodes, (node) ->
            if position is 'appendTo'
               node.appendChild if originalUsed then element.cloneNode(yes) else element 
            else if position is 'insertBefore'
               node.parentNode.insertBefore (if originalUsed then element.cloneNode(yes) else element), node
            else if position is 'insertAfter'
               node.parentNode.insertBefore (if originalUsed then element.cloneNode(yes) else element), node.nextSibling

            originalUsed = yes


   # append current nodes to other destinations
   @appendTo = (nodes..., options) -> 
      positionHandler.call(this, 'appendTo', nodes, options)


   # append some nodes to the current nodes
   @append = (nodes..., options) ->
      if options and not _.isDictionary(options)
         nodes.push(options)
         options = {}

      # compile nodes
      $(nodes).appendTo(this, options)

      return this 


   # add some content after current nodes
   @after = (nodes..., options) ->
      if options and not _.isDictionary(options)
         nodes.push(options)
         options = {}

      # compile nodes
      $(nodes).insertAfter(this, options)

      return this 


   # add some content before current nodes 
   @before = (nodes..., options) ->
      if options and not _.isDictionary(options)
         nodes.push(options)
         options = {}

      # compile nodes
      $(nodes).insertBefore(this, options)

      return this 


   # insert current nodes before other nodes
   @insertBefore = (nodes..., options) ->
      positionHandler.call(this, 'insertBefore', nodes, options)


   # insert current nodes after other nodes
   @insertAfter = (nodes..., options) ->
      positionHandler.call(this, 'insertAfter', nodes, options)


   # remove attributes from current elements
   @removeAttributes = (attributes..., options) ->
      if _.isString(options)
         attributes.push options
         options = {}

      # initiate remove attribute operation
      @operate options, (node) ->
         node.removeAttribute(attribute) for attribute in attributes

   # get and set input values
   @value = (value, options) ->
      @prop('value', value, options)


   # get and set data on the elements
   @data = (property, value) ->

      # are we setting data?
      setting = _.isString(property) and arguments.length > 1

      # initiate operation
      @operate { send: not setting }, (node) ->
         id = node.niroStoreId ?= setStoreId(node)
         if setting then data[id][property] = value else if property then data[id][property] else data[id]


   # add event listeners to the elements
   @on = (event, selector, handler, bubble, options) ->
      if _.isFunction(selector)
         options = bubble
         bubble = handler
         handler = selector
         selector = undefined

      if _.isObject(bubble)
         options = bubble
         bubble = no

      options ?= {}

      innerHandler = (event) ->
         if selector and event.target not in @querySelectorAll(selector)
            return
         
         handler.call(this, event)

      @operate options, (node) ->
         nodeData = $(node).data()
         (nodeData.eventListeners ?= []).push {innerHandler, handler}
         node.addEventListener event, innerHandler, bubble



# create Niro.Element shortcut
window.$ = (selectors...) ->
   new Niro.Element(selectors)



