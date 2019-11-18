require_relative 'compute_base'

class ComputeHumidity < ComputeBase
  def key
    :humidity
  end

  def compute_deviation?
    true
  end

  def compute_avg?
    false
  end
end
