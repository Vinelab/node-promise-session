config = require('./config')
SessionNamespace = require('../lib/SessionNamespace').klass

describe '', ->

    redis = {}
    session = {}

    # Setup
    it 'setup before all tests', ->
        redis = require('redis').createClient(config.redis.port, config.redis.host)

    describe 'SessionNamespace', ->

        beforeEach -> session = new SessionNamespace({session: prefix: 'test-session-namespace'}, '/uri/comments', redis)

        it 'generates random ID when initialized', ->
            expect(session.id).not.toBe(null)

        it 'generates the store key based on the namespace, prefix and id', ->
            expect(session.storeKey()).toBe("test-session-namespace:/uri/comments:#{session.id}")

        it 'generates unique IDs for each session to avoid key-value pair clashes', ->
            first_session = new SessionNamespace({session: prefix: 'test-session'}, '/uri/comments', redis)
            second_session = new SessionNamespace({session: prefix: 'test-session'}, '/uri/comments', redis)
            third_session = new SessionNamespace({session: prefix: 'test-session'}, '/uri/comments', redis)

            expect(first_session.id).not.toBe(second_session.id)
            expect(first_session.id).not.toBe(third_session.id)
            expect(second_session.id).not.toBe(third_session.id)

        it 'stores key-value in the session', (done)->
            session.put('my-key', 'my-value').then (result)->
                expect(result).toBe('OK')
                session.get('my-key').then (value)-> expect(value).toBe('my-value'); done()

        it 'stores a collection of key-value pairs', (done)->
            session.put({
                key1: 'val1'
                key2: 'val2'
                key3: 'val3'
            }).then (result)->
                expect(result).toBe('OK')
                session.get('key1').then (value)->
                    expect(value).toBe('val1')
                    session.get('key2').then (value)->
                        expect(value).toBe('val2')
                        session.get('key3').then (value)->
                            expect(value).toBe('val3'); done()

        it 'tells whether a key exists, and removes it if asked to do so', (done)->
            session.put('keyy', 'vall').then ->
                session.has('keyy').then (exists)->
                    expect(exists).toBe(yes)
                    session.remove('keyy').then (removed)->
                        expect(removed).toBe(yes)
                        session.has('keyy').then (found)->
                            expect(found).toBe(no); done()

        it 'destroys the session', (done)->
            session.put('somekey', 'someval').then ->
                session.destroy().then (destroyed)->
                    session.get('somekey').then (value)-> expect(value).toBe(null); done()

    # Teardown
    it 'teardown after all', ->
        redis.flushdb -> redis.end()
