expect = require('chai').expect
Registry = require('../src/registry')
_ = require('underscore')

describe 'Registry', ->

  describe 'keys()', ->
    it 'does not throw an error', ->
      expect(->
        registry = Registry.open('HKLM', '')
        console.log registry.info()
        console.log registry.keys()
        registry.close()
      ).to.not.throw(Error)

  describe 'values()', ->
    it 'does not throw an error', ->
      getAppKeys = ->
        keys = []
        parent = 'Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall'
        registry = Registry.open('HKLM', parent)
        keys = registry.keys()
        registry.close()
        return _.map keys, (key) -> parent + '\\' + key.key
      expect(->
        keys = getAppKeys()
        child = keys[5]
        registry = Registry.open('HKLM', child)
        console.log registry.values()
        registry.close()
      ).to.not.throw(Error)
