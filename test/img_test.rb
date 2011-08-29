require File.expand_path('../test_helper', __FILE__)

class ImgTest < UnitTest
  test "get img" do
    get '/images/email.png'
    assert_equal last_response.headers['Content-Length'], File.size(r("/app/images/email.png")).to_s
  end

  test "get img with cache buster" do
    get '/images/email.893748.png'
    assert_equal last_response.headers['Content-Length'], File.size(r("/app/images/email.png")).to_s
  end
end
