API = require('./win32/api')

module.exports =
class Registry

  constructor: (api) ->
    @api = api

  @open: (key, subkey) ->
    new Registry(API.OpenKey(API.CONSTANTS[key], subkey))

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
