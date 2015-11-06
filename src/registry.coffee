API = require('./win32/api')

module.exports =
class Registry

  @HKCR: API.CONSTANTS.HKEY_CLASSES_ROOT
  @HKCU: API.CONSTANTS.HKEY_CURRENT_USER
  @HKLM: API.CONSTANTS.HKEY_LOCAL_MACHINE
  @HKU: API.CONSTANTS.HKEY_USERS
  @HKCC: API.CONSTANTS.HKEY_CURRENT_CONFIG

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
