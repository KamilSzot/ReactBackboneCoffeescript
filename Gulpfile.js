var gulp = require("gulp");
var coffee = require("gulp-coffee");
var gutil = require("gulp-util");
var livereload = require("gulp-livereload");
var serve = require("gulp-serve");
var connect = require("gulp-connect");
var bowerFiles = require("main-bower-files");
var inject = require("gulp-inject");
var es = require("event-stream");
var rimraf = require("rimraf");
var less = require("gulp-less");
var plumber = require("gulp-plumber");

gulp.task('clean-libs', function(done) {
  rimraf('build/libs', done);
});

gulp.task('clean-scripts', function(done) {
  rimraf('build/js', done);
});

gulp.task('clean-styles', function(done) {
  rimraf('build/css', done);
});

gulp.task('build-libs', ['clean-libs'], function() {
  return gulp.src(bowerFiles(), { base: 'bower_components/' }).pipe(gulp.dest('build/libs/'));
});

gulp.task('build-scripts', ['clean-scripts'], function() {
  return gulp.src('*.coffee')
    .pipe(plumber())
    .pipe(coffee({ bare: true })).on('error', gutil.log)
    .pipe(gulp.dest('build/js/'));
});

gulp.task('build-styles', ['clean-styles'], function() {
  return gulp.src('*.less')
    .pipe(less({ bare: true })).on('error', gutil.log)
    .pipe(gulp.dest('build/css/'));
});

gulp.task('build-index', function() {
  return gulp.src('index.html')
    .pipe(inject(gulp.src(['build/js/*.js', 'build/css/*.css'], { read: false }), { ignorePath: 'build/' }))
    .pipe(inject(gulp.src(bowerFiles(), { read: false }), { 
      starttag: '<!-- inject:libs:{{ext}} -->', 
      ignorePath: 'bower_components/', 
      addPrefix: 'libs/' 
    }))
    .pipe(gulp.dest('build/'));
});
  
gulp.task('build', ['build-libs', 'build-scripts', 'build-styles'], function() {
  return gulp.start('build-index');
});

 gulp.task('connect', function() {
  connect.server({
    root: 'build/',
    port: 8080
  });
});
 
gulp.task('default', ['build', 'connect'], function() {
  livereload.listen();
  gulp.watch(['index.html', '*.coffee', '*.less'], ['build'])
  gulp.watch(['build/**/*']).on('change', livereload.changed);
});