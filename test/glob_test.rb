require File.expand_path('../test_helper', __FILE__)

class GlobTest < UnitTest
  class App < Main
    assets {
      serve '/js', :from => 'app/js_glob'
      js :a, '/a.js', [ '/js/**/*.js' ]
      js :b, '/b.js', [ '/js/a/b/c2/*.js' ]
      js :c, '/c.js', [ '/js/a/b/*/*.js' ]
    }

    get('/a') { js :a }
    get('/b') { js :b }
    get('/c') { js :c }
  end

  def app
    App
  end

  should "match double-star globs recursively" do
    app.stubs(:development?).returns(true)
    get '/a'
    assert body.include?("lvl1.")
    assert body.include?("lvl2.")
    assert body.include?("a/b/c1/hello.")
    assert body.include?("a/b/c2/hi.")
    assert body.include?("a/b/c2/hola.")
  end

  should "match single-star globs in filenames" do
    app.stubs(:development?).returns(true)
    get '/b'
    assert body.include?("a/b/c2/hi.")
    assert body.include?("a/b/c2/hola.")
  end

  should "match single-star globs in paths" do
    app.stubs(:development?).returns(true)
    get '/c'
    assert body.include?("a/b/c1/hello.")
    assert body.include?("a/b/c2/hi.")
    assert body.include?("a/b/c2/hola.")
  end
end
