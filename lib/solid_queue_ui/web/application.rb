# frozen_string_literal: true

module SolidQueueUi
  class WebApplication
    extend WebRouter

    CSP_HEADER = [
      "default-src 'self' https: http:",
      "child-src 'self'",
      "connect-src 'self' https: http: wss: ws:",
      "font-src 'self' https: http:",
      "frame-src 'self'",
      "img-src 'self' https: http: data:",
      "manifest-src 'self'",
      "media-src 'self'",
      "object-src 'none'",
      "script-src 'self' https: http:",
      "style-src 'self' https: http: 'unsafe-inline'",
      "worker-src 'self'",
      "base-uri 'self'"
    ].join("; ").freeze

    METRICS_PERIODS = {
      "1h" => 60,
      "2h" => 120,
      "4h" => 240,
      "8h" => 480
    }

    def initialize(klass)
      @klass = klass
    end

    def settings
      @klass.settings
    end

    def self.settings
      SolidQueueUi::Web.settings
    end

    def self.tabs
      SolidQueueUi::Web.tabs
    end

    def self.set(key, val)
      # nothing, backwards compatibility
    end

    get "/" do
      erb(:dashboard)
    end

    def call(env)
      action = self.class.match(env)
      return [404, {Rack::CONTENT_TYPE => "text/plain", Web::X_CASCADE => "pass"}, ["Not Found"]] unless action

      app = @klass
      resp = catch(:halt) do
        self.class.run_befores(app, action)
        action.instance_exec env, &action.block
      ensure
        self.class.run_afters(app, action)
      end

      case resp
      when Array
        # redirects go here
        resp
      else
        # rendered content goes here
        headers = {
          Rack::CONTENT_TYPE => "text/html",
          Rack::CACHE_CONTROL => "private, no-store",
          Web::CONTENT_LANGUAGE => action.locale,
          Web::CONTENT_SECURITY_POLICY => CSP_HEADER
        }
        # we'll let Rack calculate Content-Length for us.
        [200, headers, [resp]]
      end
    end

    def self.helpers(mod = nil, &block)
      if block
        WebAction.class_eval(&block)
      else
        WebAction.send(:include, mod)
      end
    end

    def self.before(path = nil, &block)
      befores << [path && Regexp.new("\\A#{path.gsub("*", ".*")}\\z"), block]
    end

    def self.after(path = nil, &block)
      afters << [path && Regexp.new("\\A#{path.gsub("*", ".*")}\\z"), block]
    end

    def self.run_befores(app, action)
      run_hooks(befores, app, action)
    end

    def self.run_afters(app, action)
      run_hooks(afters, app, action)
    end

    def self.run_hooks(hooks, app, action)
      hooks.select { |p, _| !p || p =~ action.env[WebRouter::PATH_INFO] }
        .each { |_, b| action.instance_exec(action.env, app, &b) }
    end

    def self.befores
      @befores ||= []
    end

    def self.afters
      @afters ||= []
    end
  end
end
