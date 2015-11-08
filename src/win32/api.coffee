ffi = require('ffi')
ref = require('ref')
WinError = require('./error')

module.exports =
class API

  @CONSTANTS: require('./constants')
  @TYPES = require('./types')

  @DLL = ffi.Library 'advapi32.dll', {
    RegOpenKeyExW: [@TYPES.LONG, [@TYPES.ULONG, @TYPES.LPCWSTR, @TYPES.DWORD,
      @TYPES.REGSAM, @TYPES.PHKEY]]
    RegQueryInfoKeyW: [@TYPES.LONG, [@TYPES.HKEY, @TYPES.LPWSTR,
      @TYPES.PDWORD, @TYPES.PDWORD, @TYPES.PDWORD, @TYPES.PDWORD,
      @TYPES.PDWORD, @TYPES.PDWORD, @TYPES.PDWORD, @TYPES.PDWORD,
      @TYPES.PDWORD, @TYPES.PFILETIME]]
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

  # https://msdn.microsoft.com/en-us/library/windows/desktop/ms724902(v=vs.85).aspx
  @QueryInfoKey: (hkey) ->
    hKey = hkey
    lpClass = @CONSTANTS.NULL
    lpcClass = @CONSTANTS.NULL
    lpReserved = @CONSTANTS.NULL
    lpcSubKeys = ref.alloc(@TYPES.DWORD)
    lpcMaxSubKeyLen = ref.alloc(@TYPES.DWORD)
    lpcMaxClassLen = @CONSTANTS.NULL
    lpcValues = ref.alloc(@TYPES.DWORD)
    lpcMaxValueNameLen = ref.alloc(@TYPES.DWORD)
    lpcMaxValueLen = ref.alloc(@TYPES.DWORD)
    lpcbSecurityDescriptor = ref.alloc(@TYPES.DWORD)
    lpftLastWriteTime = ref.alloc(@TYPES.FILETIME)
    code = @DLL.RegQueryInfoKeyW(hKey, lpClass, lpcClass, lpReserved,
      lpcSubKeys, lpcMaxSubKeyLen, lpcMaxClassLen, lpcValues,
      lpcMaxValueNameLen, lpcMaxValueLen, lpcbSecurityDescriptor,
      lpftLastWriteTime)
    if code != @CONSTANTS.ERROR_SUCCESS
      throw new WinError(code)
    return {
      lpcSubKeys: lpcSubKeys.deref()
      lpcMaxSubKeyLen: lpcMaxSubKeyLen.deref()
      lpcValues: lpcValues.deref()
      lpcMaxValueNameLen: lpcMaxValueNameLen.deref()
      lpcMaxValueLen: lpcMaxValueLen.deref()
      lpcbSecurityDescriptor: lpcbSecurityDescriptor.deref()
      lpftLastWriteTime: lpftLastWriteTime.readInt64LE(0)
    }
