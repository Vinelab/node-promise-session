### @author Abed Halawi <abed.halawi@vinelab.com> ###

q = require('q')
base64id = require('base64id')

class Session

    ###
    # Create a new instance of this class.
    #
    # @param {string} namespace
    # @param {object} RedisClient The redis client.
    ###
    constructor: (@config, @RedisClient)->
        @id = base64id.generateId()
        @is_active = yes

    ###
    # Determine whether a key exists for this session.
    #
    # @param {string} key
    ###
    has: (key)=>
        dfd = q.defer()
        @RedisClient.exists @storeKey(key), (err, exists)->
            return dfd.reject(err) if err?
            dfd.resolve(Boolean(exists))
        return dfd.promise

    ###
    # Put a key/value pair or an array of key/value pairs
    #  in the session.
    #
    #  @param {string|object} key
    #  @param {mixed} value* (Optional)
    ###
    put: (key, value)=>
        dfd = q.defer()
        # We always deal with arrays so when we receive a regular key/value pair we
        # transform them into an array of key/value pairs.
        pairs = []
        if typeof key isnt 'object'
            pairs = [@storeKey(key), value]
        else
           pairs.push(@storeKey(field), value) for field, value of key


       # Collect the arguments for redis' HMSET command.
        values = pairs
        values.push (err, result)->
            return dfd.reject(err) if err?
            dfd.resolve(result)

        @RedisClient.mset.apply(@RedisClient, values)
        return dfd.promise

    ###
    # Get an item from the session.
    #
    # @param {string|array} key
    # @param {mixed} default
    ###
    get: (key)=>
        dfd = q.defer()
        # Always expect an array, otherwise format them as an array so that we
        # only deal with one data type - array.
        keys = if typeof key isnt 'array' then [key] else key
        # Prepare arguments for redis' HMGET command
        values = keys.map(@storeKey)
        # Add the callback function as argument.
        values.push (err, result)->
            return dfd.reject(err) if err?
            # When not asking for an array of fields we'll pop the first value and return it
            result = result.pop() if typeof key is 'string'
            # Attempt to parse the results as we stringified them.
            try
                result = JSON.parse(result)._v
            catch e
                result = result

            dfd.resolve(result)

        @RedisClient.mget.apply(@RedisClient, values)

        return dfd.promise

    ###
    # Remove a key from the session.
    #
    # @param {string|array} key
    ###
    remove: (key)=>
        dfd = q.defer()
        @RedisClient.del @storeKey(key), (err, removed)=>
            return dfd.reject(err) if err?
            dfd.resolve(Boolean(removed))
        return dfd.promise

    ###
    # Destroy this session.
    ###
    destroy: =>
        dfd = q.defer()
        @RedisClient.keys "*:#{@id}:*", (err, keys)=>
            return dfd.reject(err) if err?
            @RedisClient.del keys, (err, destroyed)=>
                return dfd.reject(err) if err?
                @is_active = no
                dfd.resolve(Boolean(destroyed))
        return dfd.promise

    ###
    # Generate the hash key for this session.
    #
    # @param {string} key
    ###
    storeKey: (key)=> "#{@config.session.prefix}:#{@id}:#{key}"

module.exports.klass = Session
