gulp = require('gulp')
uglify = require('gulp-uglify')
coffee = require('gulp-coffee')
gutil = require('gutil')

gulp.task 'build', ['coffee']

gulp.task 'coffee', ->
    gulp.src("src/**/*").pipe(coffee(bare: true).on('error', gutil.log)).pipe(uglify()).pipe gulp.dest("build/")

gulp.task 'default', ->
    gulp.watch ['src/**/*'], ['coffee']