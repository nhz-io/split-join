_ = (require './package.json').gulpfile

$ =
  gulp       :require 'gulp'
  test       :require 'gulp-mocha'
  coffee     :require 'gulp-coffee'
  lint       :require 'gulp-coffeelint'
  del        :require 'del'
  replace    :require 'gulp-replace'
  run        :require 'run-sequence'

$.gulp.task 'default', (cb) -> $.run [ 'dist' ], cb

$.gulp.task 'clean', (cb) -> $.del [ _.build, _.dist ], cb

$.gulp.task 'lint', ->
  $.gulp
    .src [ "#{_.source}/**/*.coffee" ]
    .pipe $.lint './coffeelint.json'
    .pipe $.lint.reporter()

$.gulp.task 'build', [ 'clean', 'lint'], ->
  re = /((__)?extends?) = function\(child, parent\) \{.+?return child; \}/
  $.gulp
    .src [ "#{_.source}/**/*.+(coffee|litcoffee)" ]
    .pipe $.coffee bare:true
    .pipe $.replace re, '$1 = require("extends__")'
    .pipe $.gulp.dest _.build

$.gulp.task 'test', [ 'build' ], ->
  $.gulp
    .src [ "#{_.test}/**/*.js" ], read: false
    .pipe $.test reporter: 'tap'

$.gulp.task 'dist', [ 'build', 'test' ], ->
  $.gulp
    .src [ "#{_.build}/**", "!#{_.build}/test{,/**}" ]
    .pipe $.gulp.dest _.dist
