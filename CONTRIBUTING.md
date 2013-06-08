# Contributing

> If I have seen further it is by standing on the shoulders of giants. - Isaac Newton

Please follow theses simples steps to contribute to this project :

1. Fork the repo.

2. Run the tests before doing anything.

3. Add test(s) for your code modification.

4. Rebase your code onto upstream master (this repository) if not up to date.

5. Squash or fixup your commits to achieve a clean commit log.

6. Submit a pull request and ensure tests passes on travis-ci for all supported ruby versions.

## Running the tests

As simple as running `bundle exec rake` command.

The default `rake` task is `rake test`.

If you would like to test multiple ruby version using RVM, try `rvm all do rake test`.

You may setup all ruby version quickly with `rvm all do bundle install`.

## Syntax

Follow [Ruby Styleguide](https://github.com/styleguide/ruby) by Github and existing code.