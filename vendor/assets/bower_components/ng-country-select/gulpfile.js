'use strict';

var gulp = require('gulp');
var $ = require('gulp-load-plugins')();

var karma = require('karma').server;

gulp.task('scripts', function () {
    return gulp.src('src/**/*.coffee')
        .pipe($.coffeelint())
        .pipe($.coffeelint.reporter())
        .pipe($.coffee())
        .pipe(gulp.dest('dist'));
});

gulp.task('minify', ['scripts'], function () {
    gulp.src('dist/ng-country-select.js')
        .pipe($.uglify())
        .pipe($.concat('ng-country-select.min.js'))
        .pipe(gulp.dest('dist'))
});

gulp.task('clean', require('del').bind(null, ['.tmp', 'dist']));

gulp.task('test', function (done) {
    karma.start({
        configFile: __dirname + '/test/karma.conf.coffee',
        singleRun: true
    }, done);
});

gulp.task('tdd', function (done) {
    karma.start({
        configFile: __dirname + '/test/karma.conf.coffee',
        reporters: ['progress', 'osx', 'clear-screen']
    }, done);
});

gulp.task('watch', [], function () {
    gulp.watch(["src/**/*.coffee"], ["minify", "test"]);
});

gulp.task('build', ['scripts', 'minify', 'test']);

gulp.task('default', ['clean'], function () {
    gulp.start('build');
});

