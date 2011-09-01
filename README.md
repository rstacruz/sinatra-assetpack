# Sinatra AssetPack
#### Asset packer for Sinatra

This is *the* most convenient way to set up your CSS/JS (and images) in a 
Sinatra app. Seriously. No need for crappy routes to render Sass or whatever.
No-siree!

1. Drop your assets into `/app` like so (you can configure directories don't worry):
   * JavaScript/CoffeeScript files in `/app/js`
   * CSS/Sass/Less/CSS files in `/app/css`
   * Images into `/app/images`
3. Add `register Sinatra::AssetPack` and set up options to your app (see below)
4. Use `<%= css :application %>` to your layouts. Use this instead of
   messy *script* and *link* tags
5. BOOM! You're in business baby!

Setup
-----

 * Bundler? Add to *Gemfile*: `gem 'sinatra-assetpack', :require => 'sinatra/assetpack'`
 * Else: `$ gem install sinatra-assetpack`

Install the plugin and add some options. (Feel free to omit the *Optional* 
    items, they're listed here for posterity):

``` ruby
require 'sinatra/assetpack'

class App < Sinatra::Base
  set :root, File.dirname(__FILE__)
  register Sinatra::AssetPack

  assets {
    serve '/js',     from: 'app/js'        # Optional
    serve '/css',    from: 'app/css'       # Optional
    serve '/images', from: 'app/images'    # Optional

    # The second parameter defines where the compressed version will be served.
    # (Note: that parameter is optional, AssetPack will figure it out.)
    js :app, '/js/app.js', [
      '/js/vendor/**/*.js',
      '/js/app/**/*.js'
    ]

    css :application, '/css/application.css', [
      '/css/screen.css'
    ]

    js_compression  :jsmin      # Optional
    css_compression :sass       # Optional
  }
end
```

In your layouts:

``` erb
<%= css :application, :media => 'screen' %>
<%= js  :app %>
```

*(Use haml? Great! Use `!= css :youreawesome`.)*

And then what?
--------------

If you're on **development** mode, it serves each of the files as so:

``` html
<link rel='stylesheet' href='/css/screen.849289.css' media='screen' type='text/css' />
<script type='text/javascript' src='/js/vendor/jquery.283479.js'></script>
<script type='text/javascript' src='/js/vendor/underscore.589491.js'></script>
<script type='text/javascript' src='/js/app/main.589491.js'></script>
```

If you're on **production** mode, it serves a compressed version in the URLs you specify:

``` html
<link rel='stylesheet' href='/css/application.849289.css' media='screen' type='text/css' />
<script type='text/javascript' src='/js/app.589491.js'></script>
```

Features
--------

 * __CoffeeScript support__: Just add your coffee files in one of the paths 
 served (in the example, `app/js/hello.coffee`) and they will be available as JS 
 files (`http://localhost:4567/js/hello.js`).

 * __Sass/Less/SCSS support__: Works the same way. Place your dynamic CSS files 
 in there (say, `app/css/screen.sass`) and they will be available as CSS files 
 (`http://localhost:4567/css/screen.css`).

 * __Cache busting__: the `css` and `js` helpers automatically ensures the URL 
 is based on when the file was last modified. The URL `/js/jquery.js` may be 
 translated to `/js/jquery.8237898.js` to ensure visitors always get the latest 
 version.

 * __Images support__: Image filenames in your CSS will automatically get a 
 cache-busting suffix (eg, `/images/icon.742958.png`).

 * __Embedded images support__: You can embed images in your CSS files as 
 `data:` URIs by simply adding `?embed` to the end of your URL.

 * __No intermediate files needed__: You don't need to generate compiled files.
 You can, but it's optional. Keeps your source repo clean!

 * __Auto minification (with caching)__: JS and CSS files will be compressed as 
 needed.

 * __Heroku support__: Oh yes. That's right.

Compressors
-----------

By default, AssetPack uses [JSMin](http://rubygems.org/gems/jsmin) for JS 
compression, and simple regexes for CSS compression. You can specify other
compressors in the `assets` block:

``` ruby
assets {
  js_compression  :jsmin    # :jsmin | :yui | :closure
  css_compression :simple   # :simple | :sass | :yui | :sqwish
}
```


----

### YUI Compressor

``` ruby
assets {
  js_compression  :yui
  js_compression  :yui, :munge => true   # Munge variable names

  css_compression :yui
}
```

For YUI compression, you need the YUI compressor gem.

 * Bundler? Add to *Gemfile*: `gem 'yui-compressor', :require => 'yui/compressor'`
 * Else, `gem install yui-compressor`

----

### SASS compression

``` ruby
assets {
  css_compression :sass
}
```

For SASS compression, you need the Sass gem.

 * Bundler? Add to *Gemfile*: `gem 'sass'`
 * Else, `gem install sass`

----

### Sqwish CSS compression

``` ruby
assets {
  css_compression :sqwish
  css_compression :sqwish, :strict => true
}
```

[Sqwish](http://github.com/ded/sqwish) is a NodeJS-based CSS compressor.  To use 
Sqwish with AssetPack, install it using `npm install -g sqwish`. You need NodeJS 
and NPM installed.

----

### Google Closure compression

``` ruby
assets {
  js_compression :closure
  js_compression :closure, :level => "SIMPLE_OPTIMIZATIONS"
}
```

This uses the [Google closure compiler service](http://closure-compiler.appspot.com/home)
to compress your JavaScript.

Available levels: `WHITESPACE_ONLY`, `SIMPLE_OPTIMIZATIONS`, `ADVANCED_OPTIMIZATIONS`

Images
------

To show images, use the `img` helper.
This automatically adds width, height, and a cache buster thingie.
ImageMagick is required to generate full image tags with width and height.

``` html
<!-- Original: --> <%= img '/images/email.png' %>
<!-- Output:   --> <img src='/images/email.873842.png' width='16' height='16' />
```

In your CSS files, `url()`'s will automatically be translated.

``` css
/* Original: */    .email { background: url(/images/email.png); }
/* Output:   */    .email { background: url(/images/email.6783478.png); }
```

Want to embed images as `data:` URI's? Sure! Just add `?embed` at the end of the 
URL.

``` css
/* Original: */    .email { background: url(/images/email.png?embed); }
/* Output:   */    .email { background: url(data:image/png;base64,NF8dG3I...); } 
```

Need to build the files?
------------------------

Actually, you don't need to--this is optional! But add this to your Rakefile:

``` ruby
APP_FILE  = 'app.rb'
APP_CLASS = 'App'

require 'sinatra/assetpack/rake'
```

Now:

    $ rake assetpack:build

This will create files in `/public`.

API reference: assets block
---------------------------

All configuration happens in the `assets` block. You may invoke it in 2 ways:

``` ruby
class App < Sinatra::Base
  register Sinatra::AssetPack

  # Style 1
  assets do
    css :hello, [ '/css/*.css' ]
    js_compression :yui
  end

  # Style 2
  assets do |a|
    a.css :hello, ['/css/*.css' ]
    a.js_compression :yui
  end
end
```

Invoking it without a block allows you to access the options.

``` ruby
App.assets
App.assets.js_compression   #=> :yui
```

----

### assets.serve

__Usage:__ `serve 'PATH', :from => 'LOCALPATH'`

Serves files from `LOCALPATH` in the URI path `PATH`. Both parameters are 
required.

``` ruby
# ..This makes /app/javascripts/vendor/jquery.js
# available as http://localhost:4567/js/vendor/jquery.js
serve '/js', from: '/app/javascripts'
```

----

### assets.js_compression
### assets.css_compression

__Usage:__ `js_compression :ENGINE`  
__Usage:__ `js_compression :ENGINE, OPTIONS_HASH`  
__Usage:__ `css_compression :ENGINE`  
__Usage:__ `css_compression :ENGINE, OPTIONS_HASH`

Sets the compression engine to use for JavaScript or CSS. This defaults to 
`:jsmin` and `:simple`, respectively.

If `OPTIONS_HASH` is given as a hash, it sets options for the engine to use.

__Example 1:__ `css_compression :sqwish`  
__Example 2:__ `css_compression :sqwish, :strict => true`

----

### assets.js_compression_options
### assets.css_compression_options

__Usage:__ `js_compression_options HASH`  
__Usage:__ `css_compression_options HASH`

Sets the options for the compression engine to use. This is usually not needed 
as you can already set options using `js_compression` and `css_compression`.

__Example:__ `js_compression_options :munge => true`

----

### assets.css
### assets.js

__Usage:__ `css :NAME, [ PATH1, PATH2, ... ]`  
__Usage:__ `css :NAME, 'URI', [ PATH1, PATH2, ... ]`  
__Usage:__ `js  :NAME, [ PATH1, PATH2, ... ]`  
__Usage:__ `js  :NAME, 'URI', [ PATH1, PATH2, ... ]`

Adds packages to be used.

The `NAME` is a symbol defines the ID for that given package that you can use 
for the helpers. That is, If a CSS package was defined as `css :main, [ ... ]`, 
then you will need to use `<%= css :main %>` to render it in views.

the `URI` is a string that defines where the compressed version will be served.  
It is optional. If not provided, it will default to `"/type/name.type"` (eg: 
`/css/main.css`).

the `PATHs` is an array that defines files that will be served. Take note that 
this is an array of URI paths, not local paths.

If a `PATH` contains wildcards, it will be expanded in alphabetical order.  
Redundancies will be taken care of.

__Examples:__

In this example, JavaScript files will be served compressed as 
`/js/application.js` (default since no `URI` is given). The files will be taken 
from `./app/javascripts/vendor/jquery*.js`.

``` ruby
class App < Sinatra::Base
  serve '/js', from: '/app/javascripts'
  assets {
    js :application, [
      '/js/vendor/jquery.*.js',
      '/js/vendor/jquery.js'
    ]
  }
end

# In views: <%= js :application %>
```

API reference: helpers
----------------------

These are helpers you can use in your views.

----

### css

__Usage:__ `css :PACKAGE`  
__Usage:__ `css :PACKAGE_1, :PACKAGE_2, ...  :PACKAGE_N, OPTIONS_HASH`  
__Usage:__ `css :PACKAGE, OPTIONS_HASH`

Shows a CSS package named `PACKAGE`. If `OPTIONS_HASH` is given, they will we 
passed onto the `<link>` tag to be generated as attributes.

You may specify as many packages as you need, as shown in the second usage line.

__Example 1:__ `css :main, media: 'screen'`  
__Output:__ `<link rel='stylesheet' type='text/css' href='/css/main.873984.css' 
media='screen' />`

__Example 2:__ `css :base, :app, :main, media: 'screen'`

----

### js

__Usage:__ `js :PACKAGE`  
__Usage:__ `js :PACKAGE, OPTIONS_HASH`

Same as `css`, but obviously for JavaScript.

You may also specify as many packages as you need.

__Example:__ `js :main, id: 'main_script'`  
__Output:__ `<script type='text/javascript' src='/js/main.783439.js' id='main_script'></script>`

----

### img

__Usage:__ `img 'SRC'`  
__Usage:__ `img 'SRC', OPTIONS_HASH`

Shows an `<img>` tag from the given `SRC`. If the images is found in the asset 
directories (and ImageMagick is available), `width` and `height` attributes 
will be added.

If `OPTIONS_HASH` is given, they will we passed onto the `<img>` tag to be 
generated as attributes.

__Example:__ `img '/images/icon.png', alt: 'Icon'`  
__Output:__ `<img src='/images/icon.834782.png' width='24' height='24' alt='Icon' />`

Need Compass support?
---------------------

No, AssetPack doesn't have built-in Compass support, but you can use [Sinatra 
Support](http://sinefunc.com/sinatra-support):

``` ruby
# gem install sinatra/support
Encoding.default_external = 'utf-8'
require 'sinatra/support'

class Main
  register Sinatra::CompassSupport
end
```

To do
-----

AssetPack will eventually have:

 * Nested packages
 * Ignored files (to ignore included sass files and such)
 * `rake assetpack:build` should be able to output to another folder
 * Cache folder support (best if your app has many workers)
 * Refactor *Compressor* module
 * CDN (Cloudfront, S3) support
 * Better support for Compass sprites
