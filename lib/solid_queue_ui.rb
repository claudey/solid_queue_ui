require "solid_queue_ui/version"
require "solid_queue_ui/railtie"

module SolidQueueUi
  NAME = "SolidQueueUi"

  def self.load_json(string)
    JSON.parse(string)
  end

  def self.dump_json(object)
    JSON.generate(object)
  end

  def self.freeze!
    @frozen = true
    @config_blocks = nil
  end

end

require "solid_queue_ui/rails" if defined?(::Rails::Engine)
