
require File.expand_path('../test_helper', __FILE__)

class RedundantTest < UnitTest
  Main.get("/helpers/css/redundant") { css :redundant }

  test "redundant" do
    app.stubs(:development?).returns(true)
    get '/helpers/css/redundant'
    assert body.scan(/screen/).count == 1
  end
end
