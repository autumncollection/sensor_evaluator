require 'active_support/core_ext/object/blank'

class ComputeBase
  def initialize(data, reference_data)
    @data = data
    @reference_data = reference_data
  end

  def compute
    recognize(
      compute_deviation? ? compute_edge_deviation(@data) : nil,
      compute_avg? ? compute_avg(@data) : nil).to_s
  end

private

  def compute_avg(values)
    (@reference_data[key] - \
      values.inject(0.0) { |sum, value| sum + value } / values.size).abs
  end

  def compute_edge_deviation(values)
    values.map do |value|
      (@reference_data[key] - value).abs
    end.max
  end

  def recognize(deviation = nil, mean = nil)
    standards.each do |name, criteria|
      return name if criteria.blank?
      return name if (!criteria[:deviation] || value_between?(deviation, criteria[:deviation])) &&
                     (!criteria[:mean] || value_between?(mean, criteria[:mean]))
    end
  end

  def value_between?(value, criteria)
    value <= criteria
  end

  def standards
    STANDARDS[key]
  end
end
