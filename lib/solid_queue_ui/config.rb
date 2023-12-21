require "set"

module SolidQueueUi
  class Config

    DEFAULTS = {
      labels: Set.new,
      require: ".",
    }

    def initialize(options = {})
      @directory = {}
    end

    def to_json(*)
      SolidQueueUi.dump_json(@options)
    end


    private def parameter_size(handler)
      target = handler.is_a?(Proc) ? handler : handler.method(:call)
      target.parameters.size
    end

  end
end
