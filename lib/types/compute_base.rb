# frozen_string_literal: true

require 'active_support/core_ext/object/blank'

class ComputeBase
  def initialize(data, reference_data)
    @data = data
    @reference_data = reference_data
  end

  def compute
    recognize(
      compute_deviation? ? compute_max_deviation(@data) : nil,
      compute_avg? ? compute_avg(@data) : nil).to_s.gsub('_', ' ')
  end

private

  def compute_avg(values)
    (@reference_data[key] - \
      values.inject(0.0) { |sum, value| sum + value } / values.size).abs
  end

  def compute_max_deviation(values)
    values.map { |value| (@reference_data[key] - value).abs }.max
  end

  def recognize(deviation = nil, mean = nil)
    return nil if @data.blank?

    standards[:criteria].each do |name, config|
      # the last condition = else
      return name if config.blank?
      # otherwise data fit
      return name if data_fit?(mean, deviation, config)
    end
  end

  def data_fit?(mean, deviation, criteria)
    (!criteria[:deviation] || value_within?(deviation, criteria[:deviation])) &&
      (!criteria[:mean] || value_within?(mean, criteria[:mean]))
  end

  def value_within?(value, criteria)
    value <= criteria
  end

  def compute_deviation?
    @compute_deviation ||= compute?(:deviation)
  end

  def compute_avg?
    @compute_avg ||= compute?(:mean)
  end

  def compute?(what)
    !standards[:criteria].values.count { |item| item && item[what].present? }.zero?
  end

  def standards
    STANDARDS[key]
  end

  def key
    self.class::KEY
  end
end
