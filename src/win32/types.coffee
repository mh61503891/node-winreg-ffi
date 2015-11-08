ref = require('ref')
Struct = require('ref-struct')

module.exports =
class Types

  # fundamental types
  @VOID: ref.types.void
  @CHAR: ref.types.char
  @SHORT: ref.types.short
  @LONG: ref.types.long
  @UCHAR: ref.types.uchar
  @USHORT: ref.types.ushort
  @ULONG: ref.types.ulong
  @PVOID: ref.refType(@VOID)

  # windef.h
  @DWORD: @ULONG
  @PDWORD: ref.refType(@DWORD)
  @HKEY: @PVOID # HACK reinterpret_cast
  @PHKEY: ref.refType(@ULONG) # HACK reinterpret_cast
  @BYTE: @UCHAR
  @LPBYTE: ref.refType(@BYTE)

  # winnt.h
  @WCHAR: @USHORT
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
