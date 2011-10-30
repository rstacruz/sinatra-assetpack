require File.expand_path('../test_helper', __FILE__)

class AppTest < UnitTest
  test '/js/hello.js (plain js)' do
    get '/js/hello.js'
    assert body == '$(function() { alert("Hello"); });'
  end

  test '/js/hi.js (coffeescript)' do
    get '/js/hi.js'
    assert body.include? 'yo'
    assert body.include? 'x = function'
  end

  test '/js/hi.css (404)' do
    get '/js/hi.css'
    assert last_response.status == 404
  end

  test '/js/hi.7a1b92c3f56ab5cfa73c1aa8222961cf.js (with cache buster)' do
    get '/js/hello.7a1b92c3f56ab5cfa73c1aa8222961cf.js'
    assert body == '$(function() { alert("Hello"); });'
  end

  test '/js/hi.7a1b92c3f56ab5cfa73c1aa8222961cf.js (coffeescript with cache buster)' do
    get '/js/hi.7a1b92c3f56ab5cfa73c1aa8222961cf.js'
    assert_equal 200, last_response.status
    assert body.include? 'yo'
    assert body.include? 'x = function'
  end

  test 'wrong extension for static file' do
    get '/js/hello.css'
    assert last_response.status == 404
  end

  test 'matches only from the site root' do
    get '/not-the-root/js/hello.js'
    assert last_response.status == 404
  end

  test 'wrong extension for dynamic coffeescript file' do
    get '/js/hi.css'
    assert last_response.status == 404
  end

  test 'static css' do
    get '/css/style.css'
    assert body.include?('div { color: red; }')
  end

  test 'sass' do
    get '/css/screen.css'
    assert body =~ /background.*rgba.*255.*0.3/m
  end

  test "match" do
    files = app.assets.files
    assert files['/css/screen.css'] =~ /app\/css\/screen.sass/
    assert files['/js/hi.js'] =~ /app\/js\/hi.coffee/
  end

  test "helpers" do
    get '/index.html'
    assert body =~ /<script src='\/js\/hello.[a-f0-9]+.js'><\/script>/
    assert body =~ /<script src='\/js\/hi.[a-f0-9]+.js'><\/script>/
  end

  test "helpers in production (compressed html thingie)" do
    app.expects(:production?).returns(true)
    get '/index.html'
    assert body =~ /<script src='\/js\/app.[a-f0-9]+.js'><\/script>/
  end

  test "compressed js" do
    get '/js/app.js'
    assert body.include? 'function(){alert("Hello");'
    assert_includes body, "var x;x=function(){"
  end

  test "compressed js with cache bust" do
    get '/js/app.38987.js'
    assert body.include? 'function(){alert("Hello");'
    assert_includes body, "var x;x=function(){"
  end

  test "compressed css" do
    get '/css/application.css'
    assert_includes body, "rgba(0,0,255,0.3)"
  end

  test "compressed css with cache bust" do
    get '/css/application.388783.css'
    assert_includes body, "rgba(0,0,255,0.3)"
  end

  test "helpers css" do
    get '/helpers/css'
    assert body =~ %r{link rel='stylesheet' href='/css/screen.[a-f0-9]+.css' media='screen'}
  end
end
