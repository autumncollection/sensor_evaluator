# frozen_string_literal: true

require 'active_support/core_ext/object/blank'

class ComputeBase
  def initialize(data, reference_data)
    @data = data
    @reference_data = reference_data
  end

  def compute
    recognize(
      compute_deviation? ? compute_edge_deviation(@data) : nil,
      compute_avg? ? compute_avg(@data) : nil).to_s.gsub('_', ' ')
  end

private

  def compute_avg(values)
    (@reference_data[key] - \
      values.inject(0.0) { |sum, value| sum + value } / values.size).abs
  end

  def compute_edge_deviation(values)
    values.map { |value| (@reference_data[key] - value).abs }.max
  end

  def recognize(deviation = nil, mean = nil)
    return nil if @data.blank?

    standards.each do |name, criteria|
      # the last condition = else
      return name if criteria.blank?
      # otherwise data fit
      return name if data_fit?(mean, deviation, criteria)
    end
  end

  def data_fit?(mean, deviation, criteria)
    (!criteria[:deviation] || value_between?(deviation, criteria[:deviation])) &&
      (!criteria[:mean] || value_between?(mean, criteria[:mean]))
  end

  def value_between?(value, criteria)
    value <= criteria
  end

  def standards
    STANDARDS[key]
  end

  def compute_deviation?
    return @compute_deviation if defined?(@compute_deviation)

    @compute_deviation = what_compute(:deviation)
  end

  def compute_avg?
    return @compute_avg if defined?(@compute_avg)

    @compute_avg = what_compute(:mean)
  end

  def what_compute(what)
    !standards.values.count { |item| item && item[what].present? }.zero?
  end
end
