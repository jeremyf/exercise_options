# ExerciseOptions

An experimental gem for making amendments to upstream dependencies.

This project came about when I was working with Samvera's Actor Stack and needed to add additional variables to a few different classes.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add exercise_options

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install exercise_options

## Usage

```ruby
class MyObject
  def initialize(name:)
    self.name = name
  end
  attr_accessor :name
end

MyObject.prepend(
  ExerciseOptions.for(
    default_is_true: true,
    conditionally_true_with_receiver: ->(obj) { obj.name == "Hello World" },
  )
)

obj = MyObject.new(name: "Nobody")
expect(obj.default_is_true).to be_truthy
expect(obj.conditionally_true_with_receiver).to be_falsey


next_object = MyObject.new(name: "Hello World", default_is_true: false)
expect(next_object.default_is_true).to be_falsey
expect(next_object.conditionally_true_with_receiver).to be_truthy
```

## Development

Let's see if this thing make sense?
