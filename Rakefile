desc "Invokes the test suite in multiple rubies"
task :test do
  system "rvm 1.9.2@sinatra,1.8.7@sinatra rake run_test"
end

desc "Runs tests"
task :run_test do
  Dir['test/*_test.rb'].each { |f| load f }
end

task :default => :run_test
