Slimmy = require('../src/slimmy')

describe 'Slimmy', ->

  beforeEach ->
    @object = new Slimmy()

  describe '#contructor', ->
    it 'sets @property to true', ->
      expect(@object.property).to.be.true
