**NOTE**: This module is currently under development, so probably it does not work well on your environments.

# winreg-ffi

A Node.js module for binding Winreg.h using [node-ffi](https://github.com/node-ffi/node-ffi).

## Example

```example.coffee
Registry = require('winreg-ffi')

# keys
parent = 'Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall'
registry = Registry.open('HKLM', parent)
console.log keys = registry.keys()
registry.close()

# values
children = keys.map (key) -> parent + '\\' + key.name
registry = Registry.open('HKLM', children[5])
console.log registry.values()
registry.close()
```

## CLI

```
>winreg-ffi --help

A Node.js module for binding Winreg.h using node-ffi.

Usage:
  winreg-ffi --help
  winreg-ffi query KEY [--reg32 | --reg64]

Examples:
  winreg-ffi query HKLM\SOFTWARE
  winreg-ffi query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Office15.PROPLUS
```

## Development

### Test

```
npm test
```

or

```
set DEBUG=winreg-ffi:*
node_modules\.bin\mocha --compilers coffee:coffee-script/register test
```

### ToDo

- [x] RegOpenKeyExW `Registry.open()`
- [x] RegCloseKey `Registry.close()`
- [x] RegQueryInfoKey `Registry.info()`
- [x] RegEnumKeyExW `Registry.keys()`
- [x] RegEnumValueW `Registry.values()`
- [ ] RegQueryValueExW
- [ ] RegCreateKeyExW
- [ ] RegDeleteKeyW
- [ ] RegSetValueExW
- [ ] RegDeleteValueW
- [ ] RegFlushKey
- [x] CLI

## Author

- Masayuki Higashino

## License

The MIT License (MIT)
