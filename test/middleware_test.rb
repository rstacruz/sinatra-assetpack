require File.expand_path('../test_helper', __FILE__)
require 'rack/assetpack'
require 'rack/builder'

class MiddlewareTest < UnitTest
  Builder = Rack::Builder.new do
    use Rack::AssetPack do |a|
      a.root File.expand_path('../app', __FILE__)
      a.css :main, '/main.css', %w[/css/screen.css]
      a.js  :app,  '/app.js',   %w[/js/hello.js]
    end

    run Proc.new { |env|
      [200, {"Content-Type" => "text/html"},
        "<link rel='stylesheet' href = '/main.css'>" +
        "<link rel='stylesheet' href='/leavemealone.css'>" +
        "<script src='/app.js'>\n\t</script>"]
    }
  end

  def app() Builder; end

  test "middleware 2" do
    get '/main.css'
    assert last_response.status == 200
    assert last_response.headers['Content-Type'] =~ %r{^text/css}
    assert body.include?('email')
  end

  test "html transform - css pack" do
    get '/foo'
    assert last_response.status == 200
    assert last_response.headers['Content-Type'] =~ %r{^text/html}
    assert body =~ %r{/main\.[0-9]+\.css}
  end

  test "html transform - css tags" do
    get '/foo'
    assert body.include?("<link rel='stylesheet' href='/leavemealone.css'>")
  end

  test "html transform - js pack" do
    get '/foo'
    assert last_response.status == 200
    assert last_response.headers['Content-Type'] =~ %r{^text/html}
    assert body =~ %r{/app\.[0-9]+\.js}
  end
end
