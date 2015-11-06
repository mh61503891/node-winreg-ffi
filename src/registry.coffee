API = require('./win32-winreg')

module.exports =
class Registry

  constructor: (api) ->
    @api = api

  @open: (key, subkey) ->
    new Registry(API.OpenKey(key, subkey))

  close: ->
    API.CloseKey(@api)

  info: ->
    API.QueryInfoKey(@api)

  # TODO
  keys: ->

  # TODO
  values: ->
