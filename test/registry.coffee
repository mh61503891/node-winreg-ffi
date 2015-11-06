expect = require('chai').expect
Registry = require('../src/registry')

describe 'Registry', ->

  it 'does not throw an error', ->
    expect(->
      registry = Registry.open()
      registry.info()
      registry.keys()
      registry.values()
      registry.close()
    ).to.not.throw(Error)
