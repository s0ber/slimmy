Compiler = require('../src/compiler')

describe 'Compiler', ->
  beforeEach ->
    @compiler = new Compiler()

  it 'sets @property as true', ->
    expect(@compiler.property).to.be.true
