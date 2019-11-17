require_relative 'spec_helper'
require 'sensor_evaluator'

describe SensorEvaluator do
  let(:test_file) { File.read(File.join(__dir__, '../tmp/sample_data')) }
  let(:klass) { described_class.new(test_file) }
  subject { klass.perform }

  it '' do
    subject
  end
end
