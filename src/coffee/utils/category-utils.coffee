_ = require 'underscore'
Utils = require './utils'
helper = require '../helper'

###
Category Utils class
###
class CategoryUtils extends Utils

  ###
  Create list of actions for syncing categories.
  @param {object} diff result of jsondiffpatch tool.
  @return list with actions
  ###
  actionsMap: (diff, new_obj) ->
    actions = []
    return actions unless diff?
    _.each actionsList(), (item) ->
      key = item.key
      obj = diff[key]
      if obj?
        data =
          action: item.action
        if _.isArray obj
          data[key] = helper.getDeltaValue(obj)
        else
          data[key] = new_obj[key]

        actions.push data
    actions


###
Exports object
###
module.exports = CategoryUtils

#################
# Category helper methods
#################

actionsList = ->
  [
    {
      action: 'changeName'
      key: 'name'
    },
    {
      action: 'changeSlug'
      key: 'slug'
    },
    {
      action: 'setDescription'
      key: 'description'
    },
    {
      action: 'changeParent'
      key: 'parent'
#    },
#    {
#      action: 'changeOrderHint'
#      key: 'orderHint'
    }
  ]

