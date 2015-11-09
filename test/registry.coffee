expect = require('chai').expect
Registry = require('../src/registry')

describe 'Registry', ->

  it 'does not throw an error', ->
    expect(->
      registry = Registry.open(Registry.HKLM, '')
      console.log registry.info()
      console.log registry.keys()
      registry.close()
    ).to.not.throw(Error)
