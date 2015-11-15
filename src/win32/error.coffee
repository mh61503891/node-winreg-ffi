module.exports =
class WinError extends Error

  # TODO import from winerror.h
  @ERROR_CODES:
    0: 'ERROR_SUCCESS'
    2: 'ERROR_FILE_NOT_FOUND'
    5: 'ERROR_ACCESS_DENIED'
    6: 'ERROR_INVALID_HANDLE'
    14: 'ERROR_OUTOFMEMORY'
    87: 'ERROR_INVALID_PARAMETER'
    161: 'ERROR_BAD_PATHNAME'
    234: 'ERROR_MORE_DATA'
    259: 'ERROR_NO_MORE_ITEMS'

  constructor: (value) ->
    @message = "#{WinError.ERROR_CODES[value] || value}"
    @name = 'WinError'
