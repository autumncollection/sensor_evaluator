$LOAD_PATH << File.join(__dir__, 'lib')

namespace :sensor_evaluator do
  task :setup do
    require 'sensor_evaluator'
  end

  task :perform, [:file] => :setup do |_t, argument|
    klass = SensorEvaluator.new(File.read(argument[:file]))
    puts klass.perform
  end
end
