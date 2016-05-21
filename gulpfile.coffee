gulp = require('gulp')
uglify = require('gulp-uglify')
coffee = require('gulp-coffee')
gutil = require('gutil')
rename = require('gulp-rename')

gulp.task 'build', ['coffee']

gulp.task 'coffee', ->
    gulp.src('./src/map-picker.coffee').pipe(coffee(bare: true)).pipe(gulp.dest('./build')).pipe(uglify()).pipe(rename(suffix: '.min')).pipe(gulp.dest('./build'))

gulp.task 'default', ->
    gulp.watch ['./src/**/*'], ['coffee']