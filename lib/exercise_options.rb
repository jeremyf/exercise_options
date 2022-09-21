# frozen_string_literal: true

require_relative "exercise_options/version"
require "active_support"

module ExerciseOptions
  class Error < StandardError; end
  # Decorate an upstream object with additional attributes.  By including the generated module,
  # ExerciseOptions will intercept a call to `new` and apply the declared options to the newly
  # instantiated object.
  #
  # @param options [Hash<Symbol, Object>] a Hash with keys that are symbols.  Each value may be
  #        either a lambda or not.  When it is a lambda, that will be called at object
  #        initialization.  When it is not a lambda, that will be the default value at object
  #        initialization.
  #
  # @return [Module]
  #
  # @example
  #   class MyObject
  #     def initialize(name:)
  #       self.name = name
  #     end
  #     attr_accessor :name
  #   end
  #
  #   MyObject.prepend(
  #     ExerciseOptions.for(
  #       default_is_true: true,
  #       conditionally_true_with_receiver: ->(obj) { obj.name == "Hello World" },
  #     )
  #   )
  #
  #   obj = MyObject.new(name: "Nobody")
  #   expect(obj.default_is_true).to be_truthy
  #   expect(obj.conditionally_true_with_receiver).to be_falsey
  #
  #
  #   next_object = MyObject.new(name: "Hello World", default_is_true: false)
  #   expect(next_object.default_is_true).to be_falsey
  #   expect(next_object.conditionally_true_with_receiver).to be_truthy
  def self.for(**options)
    Module.new do
      extend ActiveSupport::Concern
      class_methods do
        define_method(:new) do |*args, **kwargs, &block|
          super(*args, **kwargs.except(*options.keys), &block).tap { |instance|
            options.keys.each do |key|
              value = if kwargs.key?(key)
                        kwargs.fetch(key)
                      else
                        instance.send("default_#{key}")
                      end
              instance.public_send("#{key}=", value)
            end
          }
        end
      end

      options.each do |key, value|
        attr_accessor key
        define_method "default_#{key}" do
          if value.respond_to?(:call)
            if value.arity == 1
              value.call(self)
            else
              value.call
            end
          else
            value
          end
        end
      end
    end
  end
end
