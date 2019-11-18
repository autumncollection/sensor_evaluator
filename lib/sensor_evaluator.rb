# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'time'

require 'types/compute_temperature'
require 'types/compute_monoxide'
require 'types/compute_humidity'

require_relative '../config/initializers/ini_standards'

class MissingDataReference < ArgumentError; end
class UnknownDataType < ArgumentError; end

class SensorEvaluator
  def initialize(log_content)
    @log_content = log_content
  end

  def perform
    read_content
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
    { name.to_s => compute_data(lines, name) }
  end

  def compute_data(lines, name)
    Object.const_get("compute_#{recognize_type(name)}".classify).new(
      values(lines),
      @reference_data).compute
  end

  def values(lines)
    lines.map { |line| line.split(" ")[-1].to_f }
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
        raise(UnknownDataType, name.to_s)
    end
  end

  def read_reference
    raise(MissingDataReference) unless \
      @log_content.match(/reference (?<temperature>[\d.]+)\s(?<humidity>[\d.]+)\s(?<monoxide>[\d.]+)/)

    @reference_data = %i[temperature humidity monoxide].each_with_object({}) do |key, mem|
      mem[key] = Regexp.last_match(key).to_f
    end
  end
end
