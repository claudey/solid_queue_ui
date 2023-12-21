require "rails"

module SolidQueueUi
  class Rails < ::Rails::Engine
    initializer "solid_queue_ui.active_job_integration" do
      ActiveSupport.on_load(:active_job) do
        include ::SolidQueueUi::Job::Options unless respond_to?(:solid_queue_ui_options)
      end
    end
  end
end
