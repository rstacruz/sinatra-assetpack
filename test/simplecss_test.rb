require File.expand_path('../test_helper', __FILE__)

class SimplecssTest < UnitTest
  setup do
    app.assets.css_compression = :simple
  end

  teardown do
    app.assets.css_compression = :simple
  end

  test "build" do
    get '/css/js2.css'
    assert body.include? "op:solid 1px #ddd;padding-top:20px;margin-top:20px;font-size:1em;}#info code{background"
  end
end
