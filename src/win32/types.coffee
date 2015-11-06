ref = require('ref')
Struct = require('ref-struct')

module.exports =
class Types

  # windef.h
  @NULL: ref.NULL
  @VOID: ref.types.void
  @PVOID: ref.refType(@VOID)
  @LONG: ref.types.long
  @ULONG: ref.types.ulong
  @DWORD: ref.types.ulong
  @PDWORD: ref.refType(@DWORD)
  @HKEY: @PVOID
  @PHKEY: ref.refType(@HKEY)
  @BYTE: ref.types.uchar
  @LPBYTE: ref.refType(@BYTE)

  # winnt.h
  # @WCHAR: require('./ref-wchar')
  @WCHAR: @BYTE
  @LPCWSTR: ref.refType(@WCHAR)
  @LPWSTR: ref.refType(@WCHAR)
  @ACCESS_MASK: @DWORD
  @REGSAM: @ACCESS_MASK

  # winbase.h
  @FILETIME: Struct {
    dwLowDateTime: @DWORD
    dwHighDateTime: @DWORD
  }
  @PFILETIME: ref.refType(@FILETIME)
