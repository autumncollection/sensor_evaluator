# frozen_string_literal: true

require_relative 'compute_base'

class ComputeHumidity < ComputeBase
  def key
    :humidity
  end
end
