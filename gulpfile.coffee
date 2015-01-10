# requires
gulp = require 'gulp'
path = require 'path'
less = require 'gulp-less'
concat = require 'gulp-concat'
minifier = require 'gulp-minifier'
prefix = require 'gulp-autoprefixer'
browserSync = require 'browser-sync'
reload = browserSync.reload
plumber = require 'gulp-plumber'

# icon-font
iconfont = require 'gulp-iconfont'
iconfontCss = require 'gulp-iconfont-css'

# svg-background
svgSpriteSheet = require 'gulp-svg-spritesheet'

# svg-symbol
svgstore = require 'gulp-svgstore'
inject = require 'gulp-inject'

# consts
ASSETS_PATH = 'src/public/'

# options
lessOption =
  paths: [ path.join __dirname, 'less', 'includes' ]

browserSyncOption =
  server:
    baseDir: "./src"
  port: 3000

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

# css task
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
    gulp.start 'css'

# svg symbol task
gulp.task 'svg-symbol', ->
  fileContents = (filePath, file) ->
    file.contents.toString()

  svgs = gulp.src ASSETS_PATH + 'image/svg-icon/*.svg'
  .pipe svgstore
    prefix: 'icon-'
    inlineSvg: true

  gulp.src ASSETS_PATH + '*.html'
  .pipe inject svgs, transform: fileContents
  .pipe gulp.dest 'src/'

# icon font task
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
    gulp.start 'svg-bg'

# browser sync task
gulp.task 'browser-sync', ->
  browserSync browserSyncOption

# watch or build
gulp.task 'watch', ['browser-sync'], ->
  gulp.watch ASSETS_PATH + 'css/less/**/*.less', ['css']

gulp.task 'default', ['iconfont', 'svg-symbol']