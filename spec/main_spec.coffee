Main = require('../src/main')

describe 'Main', ->

  beforeEach ->
    @object = new Main()

  describe '#contructor', ->
    it 'sets @property to true', ->
      expect(@object.property).to.be.true
