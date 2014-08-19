# Promise Session

A session mananger for Nodejs that uses Redis as an underlying store and supports namespaced sessions.


## Installation

`npm install promise-session`

## Usage

`Session = require('promise-session').create()`

#### Starting a session

`session = Session.start()`

#### Namespaced sessions
Namespaced sessions use hashes to store key/value pairs which is a recommended
way to store large numbers of keys in Redis.

`session = Session.start('namespace-here')`

##### Session ID
Every session starts with a **base64** unique ID that you can access with `session.id`

Now we can work with `session` to store, retrieve and remove key/value pairs.

##### Activity
To tell whether a session is active you may check `session.is_active`

#### Storing values

```javascript
Session.put('key', 'value')
```
You may also store multiple key/value pairs:

```javascript
Session.put({
    key1: 'val1',
    key2: 'val2',
    key3: 'val3'
});
```

#### Verifying and retrieving values

```javascript
check = Session.has('key')
check.then(function(exists){
    if (exists) {
        // yes we got it.
    } else {
        // nope.
    }
});

Session.get('key').then(function(value){
    // do things with value
});
```

Just like storing, you may verify or retrieve multiple values:

```javascript
Session.get(['key1', 'another-key', 'some-key']).then(function(values){
    // do things with the values
});
```

#### Removing values

`Session.remove('key')`

#### Destroying sessions
`session.destroy()` will erase everything related to that session

## Configuration

> The values listed below are the defaults.

```javascript
Session = require('promise-session').create({
    session: {
        prefix: 'session'
    },
    redis: {
        host: '127.0.0.1',
        port: 6379
    }
});
```

## Running Tests

- Run a Redis instance (i.e. `docker run -d -p 6379:6379 redis`)
- Perform any configuration required in `test/config.coffee`
- `npm run-script test`
