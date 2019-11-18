require 'yaml'
require 'active_support/core_ext/hash/keys'

config = YAML.safe_load(File.read(File.join(__dir__, '..', 'standards.yml')))
config.each do |key, value|
  Object.const_set(key, value.deep_symbolize_keys)
end
