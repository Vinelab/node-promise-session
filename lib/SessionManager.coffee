### @author Abed Halawi <abed.halawi@vinelab.com ###

redis = require 'redis'
extend = require 'extend'
Session = require('./Session').klass
SessionNamespace = require('./HashSession').klass

class SessionManager

    ###
    # Define some sane defaults.
    #
    # @var {object}
    ###
    defaults:
        config:
            session: prefix: 'session'
            redis:
                host: '127.0.0.1'
                port: 6379

    ###
    # Create an instance of this class.
    #
    # @param {object} config The configuration to be used.
    ###
    constructor: (config)->
        @config = extend(@defaults.config, config)
        @RedisClient = redis.createClient(config.redis.port, config.redis.host, config.redis)

    ###
    # Generate the key to be used for storing items.
    #
    # @param {string} attribute
    ###
    storeKey: (attribute)=>
        prefix = extend(@defaults.config.session, @config?.session)
        return "#{prefix}:#{attribute}"

    ###
    # Start a new session.
    #
    # @param {namespace} namespace* (Optional)
    ###
    start: (namespace)=>
        # Determine whether we should start a namespaced session or a global one.
        return if namespace? then new SessionNamespace(@config, namespace, @RedisClient) else new Session(@config, @RedisClient)

module.exports.klass = SessionManager

module.exports.create = (config)-> new SessionManager(config)

