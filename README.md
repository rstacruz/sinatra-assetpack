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
        css_compression = :simple     # Optional
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

 * __Cache busting__: the `css` and `js` helpers automatically adds

 * __Auto minification (with caching)__: 

 * __No intermediate files__: Minified files will simply be cached as needed


Helpers
-------

