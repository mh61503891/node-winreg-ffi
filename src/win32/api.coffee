ffi = require('ffi')
ref = require('ref')
WinError = require('./error')
jconv = require('jconv')

module.exports =
class API

  @CONSTANTS: require('./constants')
  @TYPES = require('./types')

  @DLL = ffi.Library 'advapi32.dll', {
    RegOpenKeyExW: [@TYPES.LONG, [@TYPES.ULONG, @TYPES.LPCWSTR, @TYPES.DWORD,
      @TYPES.REGSAM, @TYPES.PHKEY]]
    RegCloseKey: [@TYPES.LONG, [@TYPES.HKEY]]
    RegQueryInfoKeyW: [@TYPES.LONG, [@TYPES.HKEY, @TYPES.LPWSTR,
      @TYPES.PDWORD, @TYPES.PDWORD, @TYPES.PDWORD, @TYPES.PDWORD,
      @TYPES.PDWORD, @TYPES.PDWORD, @TYPES.PDWORD, @TYPES.PDWORD,
      @TYPES.PDWORD, @TYPES.PFILETIME]]
    RegQueryValueExW: [@TYPES.LONG, [@TYPES.HKEY, @TYPES.LPCWSTR,
      @TYPES.LPDWORD, @TYPES.LPDWORD, @TYPES.LPBYTE, @TYPES.LPDWORD]]
    RegEnumKeyExW: [@TYPES.LONG, [@TYPES.HKEY, @TYPES.DWORD, @TYPES.LPWSTR,
      @TYPES.PDWORD, @TYPES.PDWORD, @TYPES.LPWSTR, @TYPES.PDWORD,
      @TYPES.PFILETIME]]
    RegEnumValueW: [@TYPES.LONG, [@TYPES.HKEY, @TYPES.DWORD, @TYPES.LPWSTR,
      @TYPES.PDWORD, @TYPES.PDWORD, @TYPES.PDWORD, @TYPES.LPBYTE,
      @TYPES.PDWORD]]
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

  # TODO
  # https://msdn.microsoft.com/ja-jp/library/windows/desktop/ms724911(v=vs.85).aspx
  # @QueryValue: ->

  # https://msdn.microsoft.com/en-us/library/windows/desktop/ms724862(v=vs.85).aspx
  @EnumKey: (hkey, index, info) ->
    hKey = hkey
    dwIndex = index
    len = info.lpcMaxSubKeyLen * @TYPES.WCHAR.size
    lpName = new Buffer(len, 'utf16le')
    lpcName = ref.alloc(@TYPES.DWORD)
    lpcName.writeUInt32LE(len)
    lpReserved = @CONSTANTS.NULL
    lpClass = @CONSTANTS.NULL
    lpcClass = @CONSTANTS.NULL
    lpftLastWriteTime = ref.alloc(@TYPES.FILETIME)
    code = @DLL.RegEnumKeyExW(hKey, dwIndex, lpName, lpcName, lpReserved,
      lpClass, lpcClass, lpftLastWriteTime)
    switch code
      when @CONSTANTS.ERROR_SUCCESS
        return {
          code: code
          key: jconv.convert(lpName.reinterpretUntilZeros(@TYPES.WCHAR.size),
            'utf16le', 'utf8').toString()
          wtime: lpftLastWriteTime.readInt64LE(0)
        }
      when @CONSTANTS.ERROR_NO_MORE_ITEMS
        return {
          code: code
        }
      else
        throw new WinError(code)

  # TODO
  # https://msdn.microsoft.com/ja-jp/library/windows/desktop/ms724911(v=vs.85).aspx
  # @EnumValue ->
