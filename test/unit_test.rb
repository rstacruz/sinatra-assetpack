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

  test '/js/hello.b1946ac92492d2347c6235b4d2611184.js (with cache buster)' do
    get '/js/hello.b1946ac92492d2347c6235b4d2611184.js'
    assert_equal 200, last_response.status
    assert body == '$(function() { alert("Hello"); });'
  end

  test '/js/hi.24dcf1d7835ed64640370d52967631f8.js (coffeescript with cache buster)' do
    get '/js/hi.24dcf1d7835ed64640370d52967631f8.js'
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

  test 'returns file of requested type when mixed type assets of varying extension are present' do
    get '/packages/js_package.ec69e2cf66b1b2162f928a339e3c162e.js'
    assert body.include? 'function(){alert("Hello");'
    get '/packages/css_package.6797d3f2e04e2638eb9c460de099fcff.css'
    assert body.include? '.hi{color:red;}'
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
    app.settings.stubs(:environment).returns(:development)
    get '/index.html'
    assert body =~ /<script src='\/js\/hello.[a-f0-9]{32}.js'><\/script>/
    assert body =~ /<script src='\/js\/hi.[a-f0-9]{32}.js'><\/script>/
  end

  test "helpers in production (compressed html thingie)" do
    app.settings.stubs(:environment).returns(:production)
    get '/index.html'
    assert body =~ /<script src='\/js\/app.[a-f0-9]{32}.js'><\/script>/
  end

  test "file with multiple dots in name" do
    get '/js/lib-3.2.1.min.js'
    assert body.include? '$(function() { alert("Hello"); });'
  end

  test "file in folder glob" do
    get '/js/vendor/jquery-1.8.0.min.js'
    assert body.include? '$(function() { alert("Hello"); });'
  end

  test "compressed js with cache bust" do
    get '/js/app.b1946ac92492d2347c6235b4d2611184.js'
    assert body.include? 'function(){alert("Hello");'
    assert_includes body, "var x;x=function(){"
  end

  test "compressed css" do
    get '/css/application.css'
    assert_includes body, "rgba(0,0,255,0.3)"
  end

  test "compressed css with cache bust" do
    get '/css/application.b1946ac92492d2347c6235b4d2611184.css'
    assert_includes body, "rgba(0,0,255,0.3)"
  end

  test "helpers css (development)" do
    app.settings.stubs(:environment).returns(:development)
    get '/helpers/css'
    assert body =~ %r{link rel='stylesheet' href='/css/screen.[a-f0-9]{32}.css' media='screen'}
  end

  test "helpers css (production)" do
    app.settings.stubs(:environment).returns(:production)
    get '/helpers/css'
    assert body =~ %r{link rel='stylesheet' href='/css/application.[a-f0-9]{32}.css' media='screen'}
  end

  test 'default expiration of single assets' do
    get '/js/hi.js'
    assert_equal "public, max-age=#{86400*30}", last_response.headers['Cache-Control']
    assert_equal (Time.now + (86400*30)).httpdate, last_response.headers['Expires']
  end

  test 'custom expiration of single assets' do
    app.settings.assets.expires 86400*365, :public

    get '/js/hi.js'
    assert_equal "public, max-age=#{86400*365}", last_response.headers['Cache-Control']
    assert_equal (Time.now + (86400*365)).httpdate, last_response.headers['Expires']

    app.settings.assets.instance_variable_set('@expires', nil)
  end

  test 'default expiration of packed assets' do
    get '/js/app.js'
    assert_equal "public, max-age=#{86400*30}", last_response.headers['Cache-Control']
    assert_equal (Time.now + (86400*30)).httpdate, last_response.headers['Expires']
  end

  test 'custom expiration of packed assets' do
    app.settings.assets.expires 86400*365, :public

    get '/js/app.js'
    assert_equal "public, max-age=#{86400*365}", last_response.headers['Cache-Control']
    assert_equal (Time.now + (86400*365)).httpdate, last_response.headers['Expires']

    app.settings.assets.instance_variable_set('@expires', nil)
  end

end
