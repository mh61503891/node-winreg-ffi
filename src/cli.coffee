Registry = require('../src/registry')
meow = require('meow')
path = require('path')
fs = require('fs')
process = require('process')
usage = fs.readFileSync(path.join(__dirname, 'cli-usage.txt')).toString()
cli = meow usage, {
}

try
  desired = Registry.CONSTANTS.KEY_READ
  if cli.flags.reg32
    desired = Registry.CONSTANTS.KEY_READ | Registry.CONSTANTS.KEY_WOW64_32KEY
  if cli.flags.reg64
    desired = Registry.CONSTANTS.KEY_READ | Registry.CONSTANTS.KEY_WOW64_64KEY

  operation = cli.input[0]
  key = cli.input[1]
  keyArray = key.split('\\')
  rootKey = keyArray[0]
  subKey = keyArray[1..keyArray.length - 1].join('\\')

  getKeys = (rootKey, subKey) ->
    registry = Registry.open(rootKey, subKey, desired)
    keys = registry.keys()
    registry.close()
    return keys

  getValues = (rootKey, subKey) ->
    registry = Registry.open(rootKey, subKey, desired)
    values = registry.values()
    registry.close()
    return values

  result = {
    cli: {
      input: cli.input
      flags: cli.flags
    }
    request: {
      rootKey: rootKey
      subKey: subKey
      desired: desired
    }
    response: {
      keys: getKeys(rootKey, subKey)
      values: getValues(rootKey, subKey)
    }
  }
  process.stdout.write JSON.stringify(result, null, 2)
catch e
  console.log e
