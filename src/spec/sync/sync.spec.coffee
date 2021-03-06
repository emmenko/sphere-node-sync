_ = require 'underscore'
Q = require 'q'
Sync = require '../../lib/sync/sync'
Config = require('../../config').config.prod

OLD_OBJ =
  id: '123'
  foo: 'bar'
  version: 1

NEW_OBJ =
  id: '123'
  foo: 'qux'
  version: 1

describe 'Sync', ->

  it 'should initialize', ->
    sync = new Sync
    expect(sync).toBeDefined()
    expect(sync._actions).not.toBeDefined()

  it 'should initialize with options', ->
    sync = new Sync
      config: Config
      logConfig:
        levelStream: 'error'
        levelFile: 'error'
    expect(sync).toBeDefined()
    expect(sync._client).toBeDefined()
    expect(sync._client._rest._options.config).toEqual Config

  it 'should throw error if no credentials are given', ->
    sync = -> new Sync foo: 'bar'
    expect(sync).toThrow new Error('Missing credentials')

  _.each ['client_id', 'client_secret', 'project_key'], (key) ->
    it "should throw error if no '#{key}' is defined", ->
      opt = _.clone(Config)
      delete opt[key]
      sync = -> new Sync
        config: opt
        logConfig:
          levelStream: 'error'
          levelFile: 'error'
      expect(sync).toThrow new Error("Missing '#{key}'")


describe 'Sync.config', ->

  beforeEach ->
    @sync = new Sync

  afterEach ->
    @sync = null

  it 'should build all actions if config is not defined', ->
    spyOn(@sync, '_doMapActions').andReturn [{foo: 'bar'}]
    update = @sync.config().buildActions({foo: 'bar'}, {foo: 'qux', version: 1}).get()
    expected_update =
      actions: [
        {foo: 'bar'}
      ]
      version: 1
    expect(update).toEqual expected_update

  it 'should throw if given group is not supported', ->
    spyOn(@sync, '_doMapActions').andCallFake (type, fn) => @sync._mapActionOrNot 'base', -> [{foo: 'bar'}]
    expect(=> @sync.config([{type: 'base', group: 'foo'}]).buildActions({foo: 'bar'}, {foo: 'qux', version: 1})).toThrow new Error 'Action group \'foo\' not supported. Please use black or white.'


describe 'Sync.buildActions', ->

  beforeEach ->
    @sync = new Sync

  afterEach ->
    @sync = null

  it 'should return reference to the object', ->
    s = @sync.buildActions(NEW_OBJ, OLD_OBJ)
    expect(s).toEqual @sync

  it 'should build empty action update', ->
    update = @sync.buildActions(NEW_OBJ, OLD_OBJ).get()
    expect(update).not.toBeDefined()


describe 'Sync.filterActions', ->

  beforeEach ->
    @sync = new Sync

  afterEach ->
    @sync = null

  it 'should return reference to the object', ->
    s = @sync.filterActions()
    expect(s).toEqual @sync

  it 'should filter built actions', ->
    builtActions = ['foo', 'bar']
    spyOn(@sync, '_doMapActions').andReturn builtActions
    update = @sync.buildActions(NEW_OBJ, OLD_OBJ).filterActions (a) ->
      a isnt 'bar'
    .get()
    expect(update.actions).toEqual ['foo']

  it 'should work with no difference', ->
    update = @sync.buildActions({}, {}).filterActions (a) ->
      true
    .get()
    expect(update).toBeUndefined()

  it 'should set update to undefined if filter returns empty action list', ->
    builtActions = ['some', 'action']
    spyOn(@sync, '_doMapActions').andReturn builtActions
    update = @sync.buildActions(NEW_OBJ, OLD_OBJ).filterActions (a) ->
      false
    .get()
    expect(update).toBeUndefined()

describe 'Sync.get', ->

  beforeEach ->
    @sync = new Sync
    @sync._data =
      update: 'a'
      updateId: '123'

  afterEach ->
    @sync = null

  it 'should get data key', ->
    expect(@sync.get('update')).toBe 'a'
    expect(@sync.get('updateId')).toBe '123'
    expect(@sync.get('foo')).not.toBeDefined()

  it 'should get default data key', ->
    expect(@sync.get()).toBe 'a'

describe 'Sync.update', ->

  beforeEach ->
    @sync = new Sync
      config: Config
      logConfig:
        levelStream: 'error'
        levelFile: 'error'

  afterEach ->
    @sync = null

  it 'should throw error if no credentials were given', ->
    sync = new Sync
    expect(sync.update).toThrow new Error('Cannot update: the Rest connector wasn\'t instantiated (probabily because of missing credentials)')

  it 'should send update request', (done) ->
    spyOn(@sync, '_doUpdate').andReturn Q({foo: 'bar'})
    @sync._data =
      update:
        actions: []
        version: 1
      updateId: '123'
    @sync.update()
    .then (result) ->
      expect(result.foo).toBe 'bar'
      done()
    .fail (error) -> done(error)

  it 'should return \'304\' if there are no update actions', (done) ->
    @sync.update()
    .then (result) ->
      expect(result.statusCode).toBe 304
      expect(result.body).toBe null
      done()
    .fail (error) -> done(error)
