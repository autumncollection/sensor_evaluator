require_relative 'spec_helper'
require 'sensor_evaluator'

describe SensorEvaluator do
  let(:test_file) { File.read(File.join(__dir__, "../test/data/#{sample_file}")) }
  let(:klass) { described_class.new(test_file) }
  subject { klass.perform }

  describe 'contains correct data' do
    let(:sample_file) { 'sample_data' }
    RSpec.shared_examples 'contains right data' do
      it 'has data' do
        expect(subject[key]).to eq(assumption)
      end
    end

    context 'temp-1' do
      let(:key) { 'temp-1' }
      let(:assumption) { 'precise' }

      it_behaves_like 'contains right data'
    end

    context 'temp-1' do
      let(:key) { 'temp-2' }
      let(:assumption) { 'ultra precise' }

      it_behaves_like 'contains right data'
    end

    context 'hum-1' do
      let(:key) { 'hum-1' }
      let(:assumption) { 'keep' }

      it_behaves_like 'contains right data'
    end

    context 'hum-2' do
      let(:key) { 'hum-2' }
      let(:assumption) { 'discard' }

      it_behaves_like 'contains right data'
    end

    context 'mon-1' do
      let(:key) { 'mon-1' }
      let(:assumption) { 'keep' }

      it_behaves_like 'contains right data'
    end

    context 'mon-2' do
      let(:key) { 'mon-2' }
      let(:assumption) { 'discard' }

      it_behaves_like 'contains right data'
    end
  end

  describe 'missing data reference' do
    let(:test_file) { 'missing_reference' }

    it 'raise MissingDataReference' do
      expect { subject }.to raise_error(MissingDataReference)
    end
  end


  describe 'unknown data type' do
    let(:test_file) { 'unknown_data_type' }

    it 'raise MissingDataReference' do
      expect { subject }.to raise_error(UnknownDataType)
    end
  end
end
