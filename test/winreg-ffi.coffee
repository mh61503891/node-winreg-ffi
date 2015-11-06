expect = require('chai').expect
Winreg = require('../src/winreg-ffi')

describe 'winreg-ffi', ->
  it 'test', ->
    console.log Winreg
    expect(true).to.be.true
