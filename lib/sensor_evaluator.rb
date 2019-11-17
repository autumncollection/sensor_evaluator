# frozen_string_literal: true
require 'time'
class MissingDataReference < ArgumentError; end

class SensorEvaluator
  def initialize(log_content)
    @log_content = log_content
  end

  def perform
    read_content
  end

private

  def read_content
    @log_content.split(/thermometer|humidity|monoxide/).each do |splitted|
      case splitted
        when /reference/
          read_reference
        else
          read_data(splitted)
        end
    end
  end

  def read_data(splitted)
    lines = splitted.lines
    name  = lines.shift
    data = lines.each_with_object({}) do |line, mem|
      time, value = *line.split(" ")
      puts "#{time} #{value}"
      mem[Time.parse(time)] = value.to_f
    end
    { name: compute_temp(data) }
  end

  def compute_temp(data)
    avg = compute_avg(data.values)
    deviation = compute_deviation(data.values)
    { name: recognize_temp(avg, deviation) }
  end

  def compute_avg(values)
    avg = values.inject(0.0) { |sum, value| sum + value } / values.size
    return true if avg > @reference_data[:temperature] - 0.5 &&
      avg < @reference_data[:temperature] + 0.5
    false
  end

  def compute_deviation(values)
    values.each do |value|
      return false if value < @reference_data[:temperature] - 3 ||
        value > @reference_data[:temperature] + 3

      return true
    end
  end

  def read_reference
    raise MissingDataReference unless \
      @log_content.match(/reference (?<temperature>[\d.]+)\s(?<humidity>[\d.]+)\s(?<carbon_monoxide>[\d.]+)/)

    @reference_data = %i[temperature humidity carbon_monoxide].each_with_object({}) do |key, mem|
      mem[key] = Regexp.last_match(key).to_f
    end
  end
end
