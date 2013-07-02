require File.expand_path('../test_helper', __FILE__)

class RacklessTest < UnitTest
  class App < Main
    assets do
      css :app, '/app.css', [ '/css/*.css' ]
      js :app, '/app.js', [ '/js/hell*.js' ]
    end
    before do
      error 403, 'forbidden'  if request.env['PATH_INFO'] =~ %r{^/css|^/js}
    end
  end

  def app
    App
  end

  test "serve css without rack" do
    get '/app.css'
    assert body.include?("html,body,div,span,applet,object")
    assert body.include?("padding-top:20px;margin-top:20px;font-size:1em;}#info")
  end

  test "serve js without rack" do
    get '/app.js'
    assert body.include?("(\"Hello.2\");});$(function(){a")
  end
end
