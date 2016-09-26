gulp = require 'gulp'

coffee = require 'gulp-coffee'

argv = require('minimist')(process.argv.slice(2))
bump = require 'gulp-bump'
chromePack = require 'gulp-crx-pack'

# Filesystem
fs = require 'graceful-fs'
del = require 'del'

# Tasks
gulp.task 'clean', ->
  del.sync('compiled')

gulp.task 'coffee-compile', ->
  gulp
    .src('sources/*.coffee')
    .pipe(coffee())
    .pipe(gulp.dest('compiled'))

gulp.task 'copy-static', ->
  gulp
    .src('sources/*.png')
    .pipe(gulp.dest('compiled'))
  gulp
    .src('sources/*.json')
    .pipe(gulp.dest('compiled'))
  gulp
    .src('sources/*.js')
    .pipe(gulp.dest('compiled'))
  gulp
    .src('sources/*.html')
    .pipe(gulp.dest('compiled'))

gulp.task 'compile', [
  'clean'
  'coffee-compile'
  'copy-static'
]

gulp.task 'watch', ['compile'], ->
  gulp.watch('sources/**/*.coffee', ['coffee-compile'])
  gulp.watch('sources/*.png', ['copy-static'])
  gulp.watch('sources/*.json', ['copy-static'])
  gulp.watch('sources/*.html', ['copy-static'])

gulp.task 'bump-version', ->
  type = argv.type
  if !type in ['patch', 'minor', 'major']
    type = 'patch'

  gulp.src(
    './package.json'
  )
  .pipe bump(type: type)
  .pipe gulp.dest './'

  gulp.src([
    './sources/manifest.json',
  ])
  .pipe bump(type: type)
  .pipe gulp.dest 'sources'
  .pipe gulp.dest 'compiled'

gulp.task 'build', ['compile', 'bump-version'], ->
  gulp.src('./compiled')
  .pipe(
    chromePack(
      privateKey: fs.readFileSync './secure/key.pem', 'utf-8'
      filename: "upworker.crx")
  )
  .pipe(
    gulp.dest './builds'
  )
