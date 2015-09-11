module Storage

  def self.fetch(key, id, *args)
    worker.future.fetch(key, id, *args)
  end

  def self.worker
    Celluloid::Actor[uuid] || Worker.supervise(as: uuid)
    Celluloid::Actor[uuid]
  end

  def self.uuid
    @uuid ||= SecureRandom::uuid
  end

  class Worker
    include Celluloid

    def fetch(key, id, *args)
      fetch_key = [key, args]
      condition = Celluloid::Condition.new
      memo(fetch_key, id) << lambda { |value| condition.signal(value) }
      wait(fetch_key)
      condition.wait
    end

    def memo(key, id)
      @memo           ||= {}
      @memo[key]      ||= {}
      @memo[key][id]  ||= []
    end

    def wait(key)
      @timers       ||= {}
      @timers[key]  ||= after(0.001) { perform(key) }
      @timers[key].reset
    end

    def perform(key)
      memo = @memo[key] ; @memo[key] = nil ; @timers[key] = nil
      data = key.first.call(memo.keys, *key.last)

      memo.each do |id, callbacks|
        callbacks.each do |callback|
          callback.call(data[id])
        end
      end
    end
  end

end
