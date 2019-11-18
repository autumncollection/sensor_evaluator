require_relative 'compute_base'

class ComputeTemperature < ComputeBase
  def key
    :temperature
  end

  def compute_deviation?
    true
  end

  def compute_avg?
    true
  end
end
