expect = require('chai').expect
Registry = require('../src/registry')

describe 'Registry', ->

  describe 'info()', ->
    it 'returns a object', ->
      registry = Registry.open('HKLM',
        'Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall')
      info = registry.info()
      registry.close()
      expect(info).to.be.an.any('object')

  describe 'keys()', ->
    it 'returns an array', ->
      registry = Registry.open('HKLM',
        'Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall')
      keys = registry.keys()
      registry.close()
      expect(keys).to.be.an.any('array')

  describe 'values()', ->
    it 'returns a object', ->
      key = 'Software\\Microsoft\\Windows\\CurrentVersion'
      registry = Registry.open('HKLM', key)
      values = registry.values()
      registry.close()
      expect(values).to.be.an.any('object')

    it 'does not throw an error', ->
      getAppKeys = ->
        keys = []
        parent = 'Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall'
        registry = Registry.open('HKLM', parent)
        keys = registry.keys()
        registry.close()
        return keys.map (key) -> parent + '\\' + key.name
      expect(->
        for key in getAppKeys()
          registry = Registry.open('HKLM', key)
          values = registry.values()
          registry.close()
      ).to.not.throw(Error)
