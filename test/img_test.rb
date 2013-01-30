require File.expand_path('../test_helper', __FILE__)

class ImgTest < UnitTest
  Image = Sinatra::AssetPack::Image

  test "get img" do
    get '/images/email.png'
    assert_equal last_response.headers['Content-Length'], File.size(r("/app/images/email.png")).to_s
  end

  test "get img with cache buster" do
    get '/images/email.7a1b92c3f56ab5cfa73c1aa8222961cf.png'
    assert_equal last_response.headers['Content-Length'], File.size(r("/app/images/email.png")).to_s
  end

  test "Image[]" do
    i = Image['/app/images/email.png']
    j = Image['/app/images/email.png']

    assert j === i
  end

  test "Image[]" do
    i = Image['/app/images/email.png']
    j = Image['/app/images/email.png']

    Image.any_instance.expects(:`).times(1)
    j.dimensions
    i.dimensions
  end
end
