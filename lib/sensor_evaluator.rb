# frozen_string_literal: true
require 'time'
class MissingDataReference < ArgumentError; end
class UnknownDataType < ArgumentError; end

class SensorEvaluator
  STANDARDS = {
    temperature: {
      ultraprecise: {
        mean: 0.5, deviation: 3
      },
      very_precise: {
        mean: 0.5, deviation: 5
      },
      precise: {}
    },
    humidity: {
      keep: { deviation: 1 },
      discard: {}
    },
    monoxide: {
      keep: { deviation: 3 },
      discard: {}
    }
  }
  def initialize(log_content)
    @log_content = log_content
  end

  def perform
    JSON.generate(read_content)
  end

private

  def read_content
    @log_content.split(/thermometer|humidity|monoxide/).each_with_object({}) do |splitted, mem|
        if splitted =~ /reference/
          read_reference
        else
          mem.merge!(read_data(splitted))
        end
    end
  end

  def read_data(splitted)
    lines = splitted.lines
    name  = lines.shift.strip
    { name => send(
      "compute_#{recognize_type(name)}".to_sym,
      lines.map { |line| line.split(" ")[-1].to_f }) }
  end

  def recognize_type(name)
    case name
      when /temp/
        :temperature
      when /hum/
        :humidity
      when /mon/
        :monoxide
      else
        raise(UnknownDataType, "#{name}")
    end
  end

  def compute_monoxide(data)
    deviation = compute_edge_deviation(:monoxide, data)
    recognize(:monoxide, deviation)
  end

  def recognize(type, deviation, mean = nil)
    STANDARDS[type].each do |name, criteria|
      return name if criteria.empty?
      return name if (!criteria[:deviation] || value_between?(deviation, criteria[:deviation], type)) &&
                     (!criteria[:mean] || value_between?(mean, criteria[:mean], type))
    end
  end

  def compute_humidity(data)
    deviation = compute_edge_deviation(:humidity, data)
    recognize(:humidity, deviation)
  end

  def compute_temperature(data)
    recognize(
      :temperature,
      compute_edge_deviation(:temperature, data),
      compute_avg(:temperature, data))
  end

  def value_between?(value, criteria, _type)
    value <= criteria
  end

  def compute_avg(type, values)
    (@reference_data[type] - \
      values.inject(0.0) { |sum, value| sum + value } / values.size).abs
  end

  def compute_edge_deviation(type, values)
    values.map do |value|
      (@reference_data[type] - value).abs
    end.max
  end

  def read_reference
    raise MissingDataReference unless \
      @log_content.match(/reference (?<temperature>[\d.]+)\s(?<humidity>[\d.]+)\s(?<monoxide>[\d.]+)/)

    @reference_data = %i[temperature humidity monoxide].each_with_object({}) do |key, mem|
      mem[key] = Regexp.last_match(key).to_f
    end
  end
end
