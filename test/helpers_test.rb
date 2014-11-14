require File.expand_path('../test_helper', __FILE__)

class HelpersTest < UnitTest
  Main.get('/helper/foo') { img '/images/foo.jpg' }
  Main.get('/helper/email') { img '/images/email.png' }
  Main.get('/helper/css/all') { css :application, :sq }
  Main.get('/helper/css/app') { css :application }
  Main.get('/helper/css/sq') { css :sq }
  Main.get('/helper/foo_path') { image_path '/images/foo.jpg' }
  Main.get('/helper/email_path') { image_path '/images/email.png' }
  Main.get('/helper/absolute_url') { image_path 'https://example.s3.amazonaws.com/images/uploads/foo.jpg' }

  test "img non-existing" do
    get '/helper/foo'
    assert body == "<img src='/images/foo.jpg' />"
  end

  test "img existing (development)" do
    app.stubs(:development?).returns(true)
    get '/helper/email'

    assert body =~ %r{src='/images/email.png'}
  end

  test "img existing (production)" do
    app.stubs(:development?).returns(false)
    get '/helper/email'

    assert body =~ %r{src='/images/email.[a-f0-9]{32}.png'}
  end

  test "image_path non-existing" do
    get '/helper/foo_path'

    assert body == "/images/foo.jpg"
  end

  test "image_path existing (development)" do
    app.stubs(:development?).returns(true)
    get '/helper/email_path'

    assert body == "/images/email.png"
  end

  test "image_path existing (production)" do
    app.stubs(:development?).returns(false)
    get '/helper/email_path'

    assert body =~ %r{\A/images/email.[a-f0-9]{32}.png\z}
  end

  test "image_path absolute url (production/cdn)" do
    app.stubs(:development?).returns(false)
    get '/helper/absolute_url'

    assert body == "https://example.s3.amazonaws.com/images/uploads/foo.jpg"
  end

  test "css" do
    re = Array.new
    get '/helper/css/app'; re << body
    get '/helper/css/sq';  re << body

    get '/helper/css/all'
    assert body.gsub(/[\r\n]*/m, '') == re.join('')
  end
end
