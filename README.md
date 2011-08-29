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
   messy *<script>* and *<link>* tags
5. BOOM! You're in business baby!

Setup
-----

 * Bundler? Add to *Gemfile*: `gem 'sinatra-assetpack', :require => 'sinatra/assetpack'`
 * Else: `$ gem install sinatra-assetpack`

Install the plugin and add some options. (Feel free to omit the *Optional* 
    items, they're listed here for posterity):

``` ruby
require 'sinatra/assetpack'

class Main < Sinatra::Base
  set :root, File.dirname(__FILE__)
  register Sinatra::AssetPack

  assets {
    serve '/js',     from: 'app/js'        # Optional
    serve '/css',    from: 'app/css'       # Optional
    serve '/images', from: 'app/images'    # Optional

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
minifaction, and simple regexes for CSS minification. You can specify other
compressors in the `assets` block:

``` ruby
assets {
  js_compression  :jsmin    # :jsmin | :yui | :closure
  css_compression :simple   # :simple | :sass | :yui | :sqwish
}
```


### YUI Compressor

``` ruby
assets {
  js_compression  :yui
  css_compression :yui
  js_compression_options { :munge => true }  # Munge variable names
}
```

For YUI compression, you need the YUI compressor gem.

 * Bundler? Add to *Gemfile*: `gem 'yui-compressor', :require => 'yui/compressor'`
 * Else, `gem install yui-compressor`

### SASS compression

``` ruby
assets {
  css_compression :sass
}
```

For SASS compression, you need the Sass gem.

 * Bundler? Add to *Gemfile*: `gem 'sass'`
 * Else, `gem install sass`

### Sqwish CSS compression

``` ruby
assets {
  css_compression :sqwish
  css_compression_options { :strict => true }
}
```

[Sqwish](http://github.com/ded/sqwish) is a NodeJS-based CSS compressor.  To use 
Sqwish with AssetPack, install it using `npm install -g sqwish`. You need NodeJS 
and NPM installed.

### Google Closure compression

``` ruby
assets {
  js_compression :closure
  js_compression_options { :level => "SIMPLE_OPTIMIZATIONS" }
}
```

This uses the [Google closure compiler service](http://closure-compiler.appspot.com/home)
to compress your JavaScript.

Available levels: `WHITESPACE_ONLY`, `SIMPLE_OPTIMIZATIONS`, `ADVANCED_OPTIMIZATIONS`

Images
------

To show images, use the `img` helper.
This automatically adds width, height, and a cache buster thingie.

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
APP_CLASS = 'Main'

require 'sinatra/assetpack/rake'
```

Now:

    $ rake assetpack:build

This will create files in `/public`.

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

 * `rake assetpack:build` should be able to output to another folder
 * Cache folder support (best if your app has many workers)
 * Refactor *Compressor* module
 * CDN (Cloudfront, S3) support
 * Better support for Compass sprites
