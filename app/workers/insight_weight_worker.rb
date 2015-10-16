class InsightWeightWorker < ApplicationWorker

  def perform(id)
    Pin.find(id).rebuild_weight!
  end

end
