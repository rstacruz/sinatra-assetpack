# Sinatra AssetPack
#### Asset packer for Sinatra

Setup
-----

``` ruby
class Main < Sinatra::Base
  set :root, File.dirname(__FILE__)

  assets {
    serve '/js',     from: 'app/js'
    serve '/css',    from: 'app/css'
    serve '/images', from: 'app/images'

    js :app, '/js/app.js', [
      '/js/vendor/**/*.js',
      '/js/assets/**/*.js',
      '/js/hi.js',
      '/js/hell*.js'
    ]

    css :application, '/css/application.css', [
      '/css/screen.css'
    ]

    js_compression  = :jsmin      # Optional
    css_compression = :sass       # Optional
  }
end
```

In your layouts:

``` ruby
!= css :application, :media => 'screen'
!= js  :app
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

 * __No intermediate files needed__: You don't need to generate compiled files.
 You can, but it's optional. Keeps your source repo clean!

 * __Auto minification (with caching)__: JS and CSS files will be compressed as 
 needed.

 * __Heroku support__: That's right.

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
