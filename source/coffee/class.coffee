#  _   _ _            _____ _               
# | \ | (_)          / ____| |              
# |  \| |_ _ __ ___ | |    | | __ _ ___ ___ 
# | . ` | | '__/ _ \| |    | |/ _` / __/ __|
# | |\  | | | | (_) | |____| | (_| \__ \__ \
# |_| \_|_|_|  \___(_)_____|_|\__,_|___/___/
                                                                     
Niro.Class = (name, content, parent) ->

   # confirm  `name` is a String
   unless _.isString(name)
      throw Error "Niro.Class expects first argument (name) to be a String, type was #{typeof string}"

   # confirm `content` is Function
   unless _.isFunction(content)
      throw Error "Niro.Class expects second argument (content) to be a function, type was #{typeof content}"

   # confirm `parent` is Function
   unless _.isFunction(parent)
      throw Error "Niro.Class expects third argument to be a function, type was #{typeof parent}"

   
   # create base prototype 
   proto = Object.create(parent::) 

   # create global object 
   proto.global = {}

   # we're able to implement other classes
   implementing = null

   # the handler
   proto.implement = (service) ->
      implementing = service


   # default constructor
   proto.constructor = _.noop;

   # initialise content
   content.call(proto)

   # if we're implementing
   if implementing
      proto = _.extend( Object.create(implementing::), proto );


   # disconnect and save original constructor
   {constructor} = proto


   # create class initialiser
   initialiser = (properties) ->

      # assign before property
      property = Niro.Class.assignBeforeProperty

      # save arguments 
      args = arguments

      # implement assign before functionality
      if _.isObject(properties) and properties[property]
         delete properties[property]

         # extend instance with properties
         _.extend(this, properties)

         # assign new args
         args = _.toArray(arguments).slice(1)


      # execute the constructor
      constructor.apply(this, args)

      # return instance
      return this


   # create class function
   handler = do Function("""
      var _this = this, #{name};
      return #{name} = function(){
         _this.init.apply(this, arguments)
      };
   """).bind init: initialiser

   # extend class function with global methods
   _.extend(handler, proto.global, parent)

   # save super option
   superOption = proto.super

   # delete configuration properties
   delete proto.implement
   delete proto.global


   # create super for constructor
   constructor = Niro.Class.superMaker('constructor', constructor, implementing or parent)

   # create super for each prototype method 
   unless superOption is off 

      # loop prototype methods
      for own name, method of proto when _.isFunction(method)
         proto[name] = Niro.Class.superMaker(
            name, method, implementing?.prototype[method] and implementing or parent
         )

   # assign new class prototype
   handler:: = proto

   # save handler constructor for reference in class methods
   if handler::propertyIsEnumerable('constructor')
      Object.defineProperty handler.prototype, 'constructor',
         enumerable: no, writable: yes, value: handler


   # return amazing new class thing
   return handler


# Assign Before functionality name
Niro.Class.assignBeforeProperty = '_xAssignBefore'


# _   _ _            _____ _                          _                 _ 
# | \ | (_)          / ____| |                        | |               | |
# |  \| |_ _ __ ___ | |    | | __ _ ___ ___   _____  _| |_ ___ _ __   __| |
# | . ` | | '__/ _ \| |    | |/ _` / __/ __| / _ \ \/ / __/ _ \ '_ \ / _` |
# | |\  | | | | (_) | |____| | (_| \__ \__ \|  __/>  <| ||  __/ | | | (_| |
# |_| \_|_|_|  \___(_)_____|_|\__,_|___/___(_)___/_/\_\\__\___|_| |_|\__,_|

Niro.Class.extend = (name, content) ->   

   # confirm `name` is String
   unless _.isString(name)
      throw Error "Niro.Class.extend expects first argument (string) to be a string, type was #{typeof name}"

   # confirm `content` is Function
   unless _.isFunction(content)
      throw Error "Niro.Class.extend expects second argument (content) to be a Function, type was #{typeof content}"


   # return new class instance
   new Niro.Class(name, content, this)


#   _____                         __  __       _              
#  / ____|                       |  \/  |     | |             
# | (___  _   _ _ __   ___ _ __  | \  / | __ _| | _____ _ __  
#  \___ \| | | | '_ \ / _ \ '__| | |\/| |/ _` | |/ / _ \ '__| 
#  ____) | |_| | |_) |  __/ |    | |  | | (_| |   <  __/ |    
# |_____/ \__,_| .__/ \___|_|    |_|  |_|\__,_|_|\_\___|_|    
#              | |                                            
#              |_|                                            

Niro.Class.superMaker = (name, method, parent) ->

   return ->

      # save arguments
      args = arguments

      # the super prototype
      proto = parent::

      # monitor when super is called
      superCalled = no 

      # set up super method 
      @super = ->
         if ( superMethod = proto[name] ) and _.isFunction(superMethod) and 
         superMethod not in [method, Niro.Class]

            # use current arguments if provided
            args = arguments if arguments.length

            # call super method 
            superMethod.apply(this, args)

         superCalled = yes


      # call original method
      result = method.apply(this, args)

      # delete super now
      delete @super

      # return method response
      return result



