require File.expand_path('../test_helper', __FILE__)

class HelpersTest < UnitTest
  Main.get '/img/foo' do
    img '/images/foo.jpg'
  end

  Main.get '/img/email' do
    img '/images/email.png'
  end

  test "img non-existing" do
    get '/img/foo'
    assert body == "<img src='/images/foo.jpg' />"
  end

  test "img existing" do
    get '/img/email'
    assert body =~ %r{src='/images/email.[0-9]+.png'}
    assert body =~ %r{width='16'}
    assert body =~ %r{height='16'}
  end
end
