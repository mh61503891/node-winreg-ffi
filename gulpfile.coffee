gulp = require('gulp')
$ = require('gulp-load-plugins')
$ = $ 'rename':
  'gulp-task-listing': 'list'
path = require('path')
pkg = require('./package.json')

gulp.task 'default', ['list']

gulp.task 'list', $.list

gulp.task 'lint', ['lint-json', 'lint-coffee']

gulp.task 'lint-json', ->
  gulp.src('package.json')
    .pipe($.jsonlint())

gulp.task 'lint-coffee', ->
  gulp.src(['src/**/*.coffee', 'test/**/*.coffee'])
    .pipe($.coffeelint())
    .pipe($.coffeelint.reporter('coffeelint-stylish'))

gulp.task 'test', ['test-mocha']

gulp.task 'test-mocha', ->
  gulp.src(['test/**/*'])
    .pipe($.mocha())

gulp.task 'watch', ->
  $.watch ['src/**/*', 'test/**/*'], ->
    gulp.src(['test/**/*'])
      .pipe($.plumber(
        errorHandler: $.notify.onError("Error: <%= error.message %>")
      ))
      .pipe($.mocha(reporter: 'nyan'))
