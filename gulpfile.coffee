gulp = require('gulp')
watch = require('gulp-watch')
mocha = require('gulp-mocha')
gutil = require('gulp-util')
coffee = require('gulp-coffee')

sourceFiles = [
  'src/slimmy.coffee'
  'src/**/*.coffee'
]

specFiles = sourceFiles.concat [
  'spec/helpers/spec_helper.coffee'
  'spec/**/*.coffee'
]

gulp.task 'release', ['mocha:ci'], ->
  gulp.src(sourceFiles)
    .pipe(coffee(bare: false).on('error', gutil.log))
    .pipe(gulp.dest('lib/'))

gulp.task 'mocha:ci', ->
  gulp.src(specFiles, read: false)
    .pipe(mocha(ui: 'bdd'))
    .on 'error', (err) ->
      console.log(err.stack)
      process.exit(1)

gulp.task 'mocha:dev', ->
  gulp.src(specFiles, read: false)
    .pipe(watch(emit: 'all', (files) ->
      files
        .pipe(mocha(ui: 'bdd'))
        .on 'error', (err) ->
          console.log(err.toString())
          console.log(err.stack)
          @emit('end')
    ))

