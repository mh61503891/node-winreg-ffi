ffi = require('ffi')
ref = require('ref')
Struct = require('ref-struct')
WinError = require('./error')

module.exports =
class WinReg

  @CONSTANTS: require('./constants')
  @TYPES = require('./types')

  @DLL = ffi.Library 'advapi32.dll', {
    RegOpenKeyExW: [@TYPES.LONG, [@TYPES.ULONG, @TYPES.LPCWSTR, @TYPES.DWORD,
      @TYPES.REGSAM, @TYPES.PHKEY]]
    # RegQueryInfoKeyW: [@LONG, [@HKEY, @LPWSTR, @PDWORD, @PDWORD, @PDWORD,
    #   @PDWORD, @PDWORD, @PDWORD, @PDWORD, @PDWORD, @PDWORD, @PFILETIME]]
    # RegEnumKeyExW: [@LONG, [@HKEY, @DWORD, @LPWSTR, @PDWORD, @PDWORD, @LPWSTR,
    #   @PDWORD, @PFILETIME]]
    # RegEnumValueW: [@LONG, [@HKEY, @DWORD, @LPWSTR, @PDWORD, @PDWORD, @PDWORD,
    #   @LPBYTE, @PDWORD]]
    RegCloseKey: [@TYPES.LONG, [@TYPES.HKEY]]
  }

  # https://msdn.microsoft.com/en-us/library/windows/desktop/ms724897(v=vs.85).aspx
  @OpenKey: (hkey, subkey) ->
    hKey = hkey
    lpSubKey = new Buffer(subkey + '\0', 'utf16le')
    ulOptions = @CONSTANTS.REG_OPTION_RESERVED
    samDesired = @CONSTANTS.KEY_READ
    phkResult = ref.alloc(@TYPES.PHKEY)
    code = @DLL.RegOpenKeyExW(hKey, lpSubKey, ulOptions, samDesired, phkResult)
    if code != @CONSTANTS.ERROR_SUCCESS
      throw new WinError(code)
    return phkResult.deref()

  # https://msdn.microsoft.com/en-us/library/windows/desktop/ms724837(v=vs.85).aspx
  @CloseKey: (hkey) ->
    hKey = hkey
    code = @DLL.RegCloseKey(hKey)
    if code != @CONSTANTS.ERROR_SUCCESS
      throw new WinError(code)
