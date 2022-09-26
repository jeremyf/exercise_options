require "spec_helper"

RSpec.describe ExerciseOptions do
  context ".for" do
    let(:klass) do
      Class.new do
        def initialize(name:)
          self.name = name
        end
        attr_accessor :name
      end
    end

    before do
      klass.prepend(
        ExerciseOptions.for(
          default_is_true: true,
          conditionally_true_with_receiver: ->(obj) { obj.name == "Hello World" },
        )
      )
    end

    context "with literal value" do
      it "injects during instantiations" do
        expect(klass.new(name: "Hello").default_is_true).to eq(true)
      end
    end

    context "with calculated value" do
      it "injects derived value (from object) during instantiations", :aggregate_failures do
        expect(klass.new(name: "Hello").conditionally_true_with_receiver).to eq(false)
        expect(klass.new(name: "Hello World").conditionally_true_with_receiver).to eq(true)
      end
    end
  end
end
