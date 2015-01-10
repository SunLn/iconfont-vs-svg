# requires
gulp = require 'gulp'
gutil = require 'gulp-util'
path = require 'path'
less = require 'gulp-less'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
minifier = require 'gulp-minifier'
prefix = require 'gulp-autoprefixer'
sourcemaps = require 'gulp-sourcemaps'
spritesmith = require 'gulp.spritesmith'
svgSpriteSheet = require 'gulp-svg-spritesheet'
iconfont = require 'gulp-iconfont'
iconfontCss = require 'gulp-iconfont-css'
browserSync = require 'browser-sync'
reload = browserSync.reload
plumber = require 'gulp-plumber'

svgSprite = require 'gulp-svg-sprite'

# consts
ASSETS_PATH = 'src/public/'

# options
lessOption =
  paths: [ path.join __dirname, 'less', 'includes' ]

browserSyncOption =
  server:
    baseDir: "./src"
  port: 3000

browserSyncProdOption =
  server:
    baseDir: "./src"
  port: process.env.VCAP_APP_PORT

minifierOption =
  minify: true
  collapseWhitespace: true
  conservativeCollapse: true
  minifyJS: true
  minifyCSS: true

svgSpriteOption =
  mode:
    symbol: true

# less task
gulp.task 'less', ->
  gulp.src ASSETS_PATH + 'css/less/global.less'
    .pipe plumber()
    .pipe less(lessOption)
    .pipe prefix("last 20 version", "> 1%", "ie 8", "ie 7")
    .pipe gulp.dest ASSETS_PATH + 'css/'

gulp.task 'css', ['less'], ->
  gulp.src ASSETS_PATH + 'css/global.css'
    .pipe concat('global.min.css', {newLine: '\n'})
    .pipe minifier minifierOption
    .pipe gulp.dest ASSETS_PATH + 'css/'
    .pipe reload {stream:true}

# svg font task
gulp.task 'svg-bg', ->
  gulp.src ASSETS_PATH + 'image/svg-icon/*.svg'
  .pipe svgSpriteSheet
    cssPathSvg: '../image/background-sprite.svg'
    templateSrc: ASSETS_PATH + 'template/background-svg-less-template.tpl'
    templateDest: ASSETS_PATH + 'css/less/_background-svg-sprite.less'
  .pipe(gulp.dest ASSETS_PATH + 'image/background-sprite.svg').on 'end', ->
    gulp.start 'svg-sprite'

# svg element task
gulp.task 'svg-sprite', ->
  gulp.src ASSETS_PATH + 'image/svg-icon/*.svg'
  .pipe svgSprite svgSpriteOption
  .pipe(gulp.dest ASSETS_PATH + 'image/').on 'end', ->
    gulp.start 'iconfont'

gulp.task 'iconfont', ->
  gulp.src ASSETS_PATH + 'image/svg-icon/*.svg'
  .pipe iconfontCss
    fontName: 'iconfont'
    path: 'less'
    targetPath: '../css/less/_iconfont.less'
    fontPath: '../iconfont/'
  .pipe iconfont
    fontName: 'iconfont'
    normalize: true
  .pipe(gulp.dest ASSETS_PATH + 'iconfont/').on 'end', ->
    gulp.start 'css'

# browser sync task
gulp.task 'browser-sync', ->
  browserSync browserSyncOption

# watch or build
gulp.task 'watch', ['browser-sync'], ->
  gulp.watch ASSETS_PATH + 'css/less/**/*.less', ['css']

gulp.task 'prod', ->
  browserSync browserSyncProdOption

gulp.task 'default', ['svg-bg']