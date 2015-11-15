API = require('./win32/api')
CONSTANTS = require('./win32/constants')

module.exports =
class Registry

  @API: API
  @CONSTANTS: CONSTANTS

  constructor: (api) ->
    @api = api

  @open: (key, subkey,
    desired = CONSTANTS.KEY_READ,
    opt = CONSTANTS.REG_OPTION_RESERVED) ->
      new Registry(API.OpenKey(CONSTANTS[key], subkey, desired, opt))

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
      break if entry.code == CONSTANTS.ERROR_NO_MORE_ITEMS
      result.push(name: entry.name, wtime: entry.wtime)
      index++
    return result

  values: ->
    result = {}
    index = 0
    info = API.QueryInfoKey(@api)
    loop
      entry = API.EnumValue(@api, index, info)
      break if entry.code == CONSTANTS.ERROR_NO_MORE_ITEMS
      result[entry.name] = {
        type: entry.type
        value: entry.data
      }
      index++
    return result
