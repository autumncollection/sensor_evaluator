require_relative 'spec_helper'
require 'sensor_evaluator'

describe SensorEvaluator do
  let(:test_file) { File.read(File.join(__dir__, '../tmp/sample_data')) }
  let(:klass) { described_class.new(test_file) }
  subject { klass.perform }

  RSpec.shared_examples 'is the type' do

  end

  it 'temp-1 is precise' do
    puts subject
  end
end
