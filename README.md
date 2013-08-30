[![Build Status](https://travis-ci.org/xunker/Goodall.png?branch=master)](https://travis-ci.org/xunker/Goodall)
# Goodall

Goodall provides an easy interface for documenting your API while you
write your integration tests.

It is compatible with Rspec, Cucumber and test-unit, as well as others. It
currently supports JSON and XML APIs, but modules can be easily written to
handler other types.

Goodall is named after researcher Jane Goodall, who has spent her life observing and
documenting the behviour of chimpanzees.

## Purpose

Goodall is a gemified version of the ideas in outlined a few years ago in
this blog post: http://n4k3d.com/blog/2011/08/19/generate-easy-up-to-date-rails-api-docs-with-cucumber/

The basic idea is that you are writing integration tests anyway, you are 90%
there. All that was left was to record the requests and responses to a text
file.  For example, the following cucumber test:

```cucumber
  Feature: /widgets
    Scenario: Get a list of all widgets
      Given the following widget exists:
        | name             | job         |
        | Billy the Widget | Be a widget |
        | Sally the Widget | Be a widget |
      When I GET "/widgets"
      Then I should get a successful response
      And the response should include 2 widgets
      And the response should include the Widget data for "Billy the Widget"
      And the response should include the Widget data for "Sally the Widget"

    Scenario: Create a new widget
      Given I have a JSON request for "widget"
        | name | Bob the Widget |
        | job  | Be a widget    |
      And I POST that JSON to "/widgets.json"
      Then I should get a successful response
      And the response should include the Widget data for "Bob the Widget"
```

.. would then generate the following documentation:

```
  ——————————————————————————–
  Feature: /widgets

  Scenario: Get a list of all widgets
  GET /widgets.json
  RESPONSE:
  {
    "widgets" : [
      {
        "name" : "Billy the Widget",
        "job" : "Be a widget"
      },
      {
        "name" : "Sally the Widget",
        "job" : "Be a widget"
      }
    ]
  }

  Scenario: Create a new widget
  POST /widgets.json:
  {
    "widget" : {
      "name" : "Bob the Widget",
      "job" : "Be a widget"
    }
  }
  RESPONSE:
  {
    "widget" : {
      "name" : "Billy the Widget",
      "job" : "Be a widget"
    }
  }
```

## Installation

Add this line to your application's Gemfile:

  gem 'goodall'

And then execute:

  $ bundle

Or install it yourself as:

  $ gem install goodall

## Usage

### Cucumber

In your *env.rv* file, require 'goodall/cucumber' and either of the JSON
or XML handlers. Or both, if you need them.

```ruby
  # env.rb
  require 'goodall/cucumber'
  require 'goodall/handler/json' # or/and 'goodall/handler/xml'
```

In your features, where you want to log a request or response, call either
*Goodall.document_request* or *Goodall.document_response*.

For cucumber, the best way is to have often-reused methods in each scenario, and then put the Goodall methods call in those. Take this example feature:

```Cucumber
  # something.feature
  Given I get "/some/api.json"
  Then the response should be valid json
  And the response should should be successful

  # something_steps.rb

  Given /^I get \"(.+)\"$/ do |path|
    get(path)
    Goodall.document_request(:get, path)
  end

  Given /^the response should be valid json$/ do
    Goodall.document_response(last_response.body)
    @json_response = MultiJson.load(last_response.body)
  end

  Given /^the response should be successul$/ do
    @last_response['success'].should be_true
  end
```

The steps "I get (.+)" and "the response should be valid json" are steps I
will use in almost every scenario, so it is the perfect place for the Goodall
calls. Using Goodall in these frequently used steps is key for ease-of-use.

_IMPORTANT NOTE_: Using the cucumber helpers, Goodall will NOT log unless
executed via the rake task "rake cucumber:document". To force Goodall to
log, please set the environment variable 'ENABLE_GOODALL' to a non-nil
value. For example:

```
  ENABLE_GOODALL=true cucumber features/
```

### Rspec

In your *spec_helper.rb* file, require 'goodall/rspec' and either of the
JSON or XML handlers. Or both, if you need them.

```ruby
  # spec_helper.rb
  require 'goodall/rspec'
  require 'goodall/handler/json' # or/and 'goodall/handler/xml'
```

For controller specs, re-use can be acheived by making a delegation method
for the get/post/put/delete/patch verbs:

```ruby
  # spec_helper.rb

  def documented_get(*args)
    Goodall.document_request(:get, args[0])
    get_response = get(args)
    Goodall.document_response(response.body)
    get_response
  end

  # some_controller_spec.rb
  describe SomeController do
    describe "GET foo" do
      it "should return a body containing 'blah'" do

        documented_get(:foo) # replaces get(:foo)
        expect(response.body).to include?('blah')

      end
    end
  end
```

_IMPORTANT NOTE_: Using the rspec helpers, Goodall will NOT log unless
executed via the rake task "rake rspec:document". To force Goodall to
log, please set the environment variable 'ENABLE_GOODALL' to a non-nil
value. For example:

```shell
  ENABLE_GOODALL=true rspec spec/
```

### Test Unit and derivatives, and others

If you are not using any of the convenience wrappers for rspec or cucumber,
there is more work to be done when using Goodall.

First, like others, require the files:

```ruby
  require 'goodall'
  require 'goodall/handler/json' # or/and 'goodall/handler/xml'
```  

You will also need to set the path of the file for output. If you choose
not the set this, the default will be used which is "./api_docs.txt".
You can override this by:

```ruby
  Goodall.output_path = "./some/path/file.txt"
```

Enabing the logging process involves setting the *enabled* property. It is
disabled by default, which means that Goodall will not document unless
explicity told to do so. You can enable logging with

```ruby
  Goodall.enabled = true
```

### Rake task

To automate the creation of documentation, a rake task can be added that
automatically set the output file and triggers the tests.

```ruby
  # Rakefile
  require 'goodall/rake_task'
```

This unlocks the following rake commands:

```shell
  rake cucumber:document   # Run cucumber and write Goodall documentation
  rake spec:document       # Run rspec tests and write Goodall documentation
  rake goodall:output_path # Show current Goodall documentation output path
```

By default, the output path will be 'doc/api_docs.txt' when run with this
rake task.

## Handlers

By default, Goodall includes handlers for XML and JSON. This means that the
logged output can be parsed from these formats and pretty-printed correctly
to the documention file.

If only one handler is required in your config, Goodall assumes you want to
use that one all the time.  For example:

```ruby
  require 'goodall'
  require 'goodall/handler/json'

  Goodall.document_reponse(response.body)
```

..will assume *response.body* is JSON and will parse it as such. If you were
to swap "goodall/handler/json" with "goodall/handler/xml" then the response
would be assumed to be XML.

If you need to use both formats at the same time, you can include both
handlers and set the actuve handler by name.

```ruby
  require 'goodall'
  require 'goodall/handler/json'
  require 'goodall/handler/xml'

  Goodall.set_handler(:json)
  Goodall.document_response(response.body) # json response

  Goodall.set_handler(:xml)
  Goodall.document_response(response.body) # xml response
```

In the above case, the default handler would be XML since it was required
last.

### Writing new handlers

Please see *lib/goodall/handler/json.rb* for a good example. A handler will
need to do two things:

**Implement #parse_payload**: accepts a data structure and is expected to
return a pretty-printed string representing that data.

**Register itself as a handler**: This is done by calling:
  
  ```ruby
    Goodall.register_handler(:handler_name, self)
  ```
..where *:handler_name* is a **symbol** for what type of data is being
handled, and self is the **class** of the handler.

## Methods

Documented with rdoc.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
