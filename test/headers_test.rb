require File.expand_path('../test_helper', __FILE__)

class HeadersTest < UnitTest
  setup do
    app.set :reload_templates, true

    @file = File.join(app.root, 'app', 'packages', 'a_package', 'package.css')
    FileUtils.touch(@file)
    @httpdate = File.mtime(@file).httpdate
  end

  test "individual route" do
    get '/packages/a_package/package.css'
    assert_equal @httpdate, last_response.headers['Last-Modified']
  end

  test "package route" do
    get '/packages/css_package.6797d3f2e04e2638eb9c460de099fcff.css'
    assert_equal @httpdate, last_response.headers['Last-Modified']
  end
end
