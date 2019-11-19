# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'time'

require 'types/compute_thermometer'
require 'types/compute_monoxide'
require 'types/compute_humidity'

require_relative '../config/initializers/ini_standards'

class MissingDataReference < ArgumentError; end
class UnknownDataType < ArgumentError; end

class SensorEvaluator
  REFERENCE_REGEXP = /reference/.freeze

  def initialize(log_content)
    @log_content = log_content
  end

  def perform
    read_content
  end

private

  def read_content
    @log_content.split(split_regexp).each_with_object({}) do |splitted, mem|
      if splitted =~ REFERENCE_REGEXP
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
    STANDARDS.each do |key, config|
      return key.to_sym if name =~ Regexp.new(config[:recognize_regexp])
    end
    raise(UnknownDataType, name.to_s)
  end

  def read_reference
    raise(MissingDataReference) unless @log_content.match(reference_regexp)

    @reference_data = reference.each_with_object({}) do |key, mem|
      mem[key.to_sym] = Regexp.last_match(key.to_sym).to_f
    end
  end

  def reference_regexp
    standards = reference.map do |name|
      "(?<#{name}>[\\d.]+)"
    end.join("\\s")

    Regexp.new("reference #{standards}")
  end

  def reference
    @reference ||= STANDARDS.sort_by { |_, config| config[:position] }.to_h.keys
  end

  def split_regexp
    Regexp.new(STANDARDS.map do |_, config|
      config[:split_regexp]
    end.join('|'))
  end
end
