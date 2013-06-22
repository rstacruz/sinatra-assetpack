require 'contest'
require 'rack/test'
require 'mocha/setup'

ENV['RACK_ENV'] = 'test'

require File.expand_path('../app/app.rb', __FILE__)

class UnitTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Main
  end

  def d
    puts "-"*80
    puts "#{last_response.status}"
    y last_response.original_headers
    puts "-"*80
    puts ""
    puts last_response.body.gsub(/^/m, '    ')
    puts ""
  end

  def body
    last_response.body.strip
  end

  def r(*a)
    File.join app.root, *a
  end

  def assert_includes(haystack, needle)
    assert haystack.include?(needle), "Expected #{haystack.inspect} to include #{needle.inspect}."
  end
end

