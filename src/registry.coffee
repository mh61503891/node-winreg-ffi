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

  keys: ->
    result = []
    index = 0
    info = API.QueryInfoKey(@api)
    loop
      entry = API.EnumKey(@api, index, info)
      break if entry.code == API.CONSTANTS.ERROR_NO_MORE_ITEMS
      result.push(key: entry.key, wtime: entry.wtime)
      index++
    return result

  values: ->
    result = []
    index = 0
    info = API.QueryInfoKey(@api)
    loop
      entry = API.EnumValue(@api, index, info)
      break if entry.code == API.CONSTANTS.ERROR_NO_MORE_ITEMS
      result.push(type: entry.type, name: entry.name, value: entry.data)
      index++
    return result
