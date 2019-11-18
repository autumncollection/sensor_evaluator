require_relative 'compute_base'

class ComputeMonoxide < ComputeBase
  def key
    :monoxide
  end

  def compute_deviation?
    true
  end

  def compute_avg?
    false
  end
end
