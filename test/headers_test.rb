require File.expand_path('../test_helper', __FILE__)

class HeadersTest < UnitTest
  setup do
    app.set :reload_templates, true

    @file = File.join(app.root, 'app', 'packages', 'a_package', 'package.js')
    FileUtils.touch(@file)
    @httpdate = File.mtime(@file).httpdate
  end

  test "individual route" do
    get '/packages/a_package/package.js'
    assert_equal @httpdate, last_response.headers['Last-Modified']
  end

  test "package route" do
    get '/packages/a_package.b1946ac92492d2347c6235b4d2611184.js'
    assert_equal @httpdate, last_response.headers['Last-Modified']
  end
end
