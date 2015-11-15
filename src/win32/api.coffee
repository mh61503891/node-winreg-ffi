ffi = require('ffi')
ref = require('ref')
WinError = require('./error')
jconv = require('jconv')
debug = require('debug')('winreg-ffi:api')
CONSTANTS = require('./constants')

toString = (buffer, size) ->
  jconv.convert(buffer.slice(0, size), 'utf16le', 'utf8').toString()

module.exports =
class API

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
  @OpenKey: (hkey, subkey, desired, opt) ->
    hKey = hkey
    lpSubKey = new Buffer(subkey + '\0', 'utf16le')
    ulOptions = CONSTANTS.REG_OPTION_RESERVED
    samDesired = desired
    phkResult = ref.alloc(@TYPES.PHKEY)
    code = @DLL.RegOpenKeyExW(hKey, lpSubKey, ulOptions, samDesired, phkResult)
    if code != CONSTANTS.ERROR_SUCCESS
      throw new WinError(code)
    return phkResult.deref()

  # https://msdn.microsoft.com/en-us/library/windows/desktop/ms724837(v=vs.85).aspx
  @CloseKey: (hkey) ->
    hKey = hkey
    code = @DLL.RegCloseKey(hKey)
    if code != CONSTANTS.ERROR_SUCCESS
      throw new WinError(code)

  # https://msdn.microsoft.com/en-us/library/windows/desktop/ms724902(v=vs.85).aspx
  @QueryInfoKey: (hkey) ->
    hKey = hkey
    lpClass = CONSTANTS.NULL
    lpcClass = CONSTANTS.NULL
    lpReserved = CONSTANTS.NULL
    lpcSubKeys = ref.alloc(@TYPES.DWORD)
    lpcMaxSubKeyLen = ref.alloc(@TYPES.DWORD)
    lpcMaxClassLen = CONSTANTS.NULL
    lpcValues = ref.alloc(@TYPES.DWORD)
    lpcMaxValueNameLen = ref.alloc(@TYPES.DWORD)
    lpcMaxValueLen = ref.alloc(@TYPES.DWORD)
    lpcbSecurityDescriptor = ref.alloc(@TYPES.DWORD)
    lpftLastWriteTime = ref.alloc(@TYPES.FILETIME)
    code = @DLL.RegQueryInfoKeyW(hKey, lpClass, lpcClass, lpReserved,
      lpcSubKeys, lpcMaxSubKeyLen, lpcMaxClassLen, lpcValues,
      lpcMaxValueNameLen, lpcMaxValueLen, lpcbSecurityDescriptor,
      lpftLastWriteTime)
    if code != CONSTANTS.ERROR_SUCCESS
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
    lpReserved = CONSTANTS.NULL
    lpClass = CONSTANTS.NULL
    lpcClass = CONSTANTS.NULL
    lpftLastWriteTime = ref.alloc(@TYPES.FILETIME)
    code = @DLL.RegEnumKeyExW(hKey, dwIndex, lpName, lpcName, lpReserved,
      lpClass, lpcClass, lpftLastWriteTime)
    switch code
      when CONSTANTS.ERROR_SUCCESS
        return {
          code: code
          key: toString(lpName, lpcName.deref() * @TYPES.TCHAR.size)
          wtime: lpftLastWriteTime.readInt64LE(0)
        }
      when CONSTANTS.ERROR_NO_MORE_ITEMS
        return {
          code: code
        }
      else
        throw new WinError(code)

  # https://msdn.microsoft.com/ja-jp/library/windows/desktop/ms724911(v=vs.85).aspx
  @EnumValue: (hkey, index, info) ->
    # handle key
    hKey = hkey
    # index
    dwIndex = index
    # name
    vnlen = info.lpcMaxValueNameLen * @TYPES.WCHAR.size
    lpValueName = new Buffer(vnlen, 'utf16le')
    lpcValueName = ref.alloc(@TYPES.DWORD)
    lpcValueName.writeUInt32LE(vnlen)
    # reserved
    lpReserved = CONSTANTS.NULL
    # type
    lpType = ref.alloc(@TYPES.DWORD)
    # value
    vlen = info.lpcMaxValueLen * @TYPES.WCHAR.size
    lpData = new Buffer(vlen, 'utf16le')
    lpcbData = ref.alloc(@TYPES.DWORD)
    lpcbData.writeUInt32LE(vlen)

    debug '%j', {
      dwIndex: dwIndex
      vnlen: vnlen
      lpcValueName: lpcValueName.deref()
    }

    code = @DLL.RegEnumValueW(hKey, dwIndex, lpValueName, lpcValueName,
      lpReserved, lpType, lpData, lpcbData)

    switch code
      when CONSTANTS.ERROR_SUCCESS
        return @dispatch(code, lpType, lpValueName, lpcValueName,
          lpData, lpcbData)
      when CONSTANTS.ERROR_NO_MORE_ITEMS
        return {code: code}
      else
        throw new WinError(code)

  @dispatch: (code, type, name, cname, data, cdata) ->
    jcode = code
    jtype = type.deref()
    jname = toString(name, cname.deref() * @TYPES.TCHAR.size)
    jdata = switch jtype
      when CONSTANTS.REG_NONE # 0
        data
      when CONSTANTS.REG_SZ # 1
        toString(data, cdata.deref() - @TYPES.TCHAR.size)
      when CONSTANTS.REG_EXPAND_SZ # 2
        toString(data, cdata.deref() - @TYPES.TCHAR.size)
      when CONSTANTS.REG_BINARY # 3
        data
      when CONSTANTS.REG_DWORD_LITTLE_ENDIAN, CONSTANTS.REG_DWORD # 4
        data.readUInt32LE()
      when CONSTANTS.REG_DWORD_BIG_ENDIAN # 5
        data.readUInt32BE()
      when CONSTANTS.REG_MULTI_SZ #7
        data # TODO
      when CONSTANTS.REG_QWORD_LITTLE_ENDIAN, CONSTANTS.REG_QWORD # 11
        data.readInt64LE(0)
      when CONSTANTS.REG_LINK # 6
        throw new Error("Type #{type} is not supported.")
      when CONSTANTS.REG_RESOURCE_LIST # 8
        throw new Error("Type #{type} is not supported.")
      when CONSTANTS.REG_FULL_RESOURCE_DESCRIPTOR # 9
        throw new Error("Type #{type} is not supported.")
      when CONSTANTS.REG_RESOURCE_REQUIREMENTS_LIST # 10
        throw new Error("Type #{type} is not supported.")
      else
        throw new Error("Type #{type} is invalid.")
    entry = {
      code: jcode
      name: jname
      type: jtype
      data: jdata
    }
    debug 'dispatch: %j', entry
    return entry
