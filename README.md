Slimmy
=====
[![Build Status](https://travis-ci.org/s0ber/slimmy.png?branch=master)](https://travis-ci.org/s0ber/slimmy)

## Usage

Create slimmy instance.

```
Slimmy = require 'slimmy'
slimmy = new Slimmy()
```

You then can convert file.

```
slimmy.convertFile('~/my_rails_app/app/views/layouts/application.html.haml')
```

Or the whole directory (recursively).

```
slimmy.convertDir('~/my_rails_app/app/views/')
```

Or just a string.

```
filePath = '~/my_rails_app/app/views/layouts/application.html.haml'
hamlString = require('fs').readFileSync(filePath).toString()

slimmy.convertString(hamlString).then (compiler) ->
  # then we can access compiler's buffer
  console.log(compiler.buffer)
```

## Development

Prepare development environment: install haml, install node packages.

```cmd
gem install haml
npm install -g gulp
npm install -g coffeegulp
npm install
```

Run tests in development mode.

```cmd
coffeegulp mocha:dev
```

Code!
