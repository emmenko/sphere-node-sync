_ = require 'underscore'
_.mixin deepClone: (obj) -> JSON.parse(JSON.stringify(obj))
CategoryUtils = require '../../lib/utils/category-utils'

describe 'CategoryUtils', ->
  beforeEach ->
    @utils = new CategoryUtils()

  afterEach ->
    @utils = null

  describe 'actionsMap', ->
    it 'should create no actions for the same category', ->
      category =
        id: 'same'
        name:
          de: 'bla'
          en: 'foo'

      delta = @utils.diff category, category
      update = @utils.actionsMap delta, category

      expect(update).toEqual []


    it 'should create action to change name', ->
      category =
        id: '123'
        name:
          de: 'bla'
          en: 'foo'

      otherCategory = _.deepClone category
      otherCategory.name.en = 'bar'

      delta = @utils.diff category, otherCategory
      update = @utils.actionsMap delta, otherCategory
      expect(update).toEqual [
        { action: 'changeName', name: { de: 'bla', en: 'bar' } }
      ]

    it 'should create action to change description', ->
      category =
        id: '123'
        name:
          en: 'foo'
        description:
          en: 'foo bar'

      otherCategory = _.deepClone category
      otherCategory.description.en = "some\nmulti line\n text"
      otherCategory.description.de = 'eine andere Sprache'

      delta = @utils.diff category, otherCategory
      update = @utils.actionsMap delta, otherCategory
      expect(update).toEqual [
        { action: 'setDescription', description: { de: 'eine andere Sprache', en: "some\nmulti line\n text" } }
      ]

    it 'should create action to delete description', ->
      category =
        id: '123'
        description:
          en: 'foo bar'

      otherCategory = _.deepClone category
      delete otherCategory.description

      delta = @utils.diff category, otherCategory
      update = @utils.actionsMap delta, otherCategory
      expect(update).toEqual [
        { action: 'setDescription' }
      ]

    it 'should create action to change slug', ->
      category =
        id: '123'
        name:
          en: 'foo'
        slug:
          en: 'foo-bar'

      otherCategory = _.deepClone category
      delete otherCategory.slug.en
      otherCategory.slug.de = 'nice-url'

      delta = @utils.diff category, otherCategory
      update = @utils.actionsMap delta, otherCategory
      expect(update).toEqual [
        { action: 'changeSlug', slug: { de: 'nice-url' } }
      ]

    it 'should create action to change parent', ->
      category =
        id: '123'
        parent:
          typeId: 'category'
          id: 'p1'

      otherCategory = _.deepClone category
      otherCategory.parent.id = 'p2'

      delta = @utils.diff category, otherCategory
      update = @utils.actionsMap delta, otherCategory
      expect(update).toEqual [
        { action: 'changeParent', parent: { typeId: 'category', id: 'p2' } }
      ]
