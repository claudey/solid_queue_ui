# frozen_string_literal: true

require "uri"
require "set"
require "yaml"
require "cgi"

module SolidQueueUi
  # This is not a public API
  module WebHelpers
    def strings(lang)
      @strings ||= {}

      @strings[lang] ||= settings.locales.each_with_object({}) do |path, global|
        find_locale_files(lang).each do |file|
          strs = YAML.safe_load(File.read(file))
          global.merge!(strs[lang])
        end
      end
    end

    def to_json(x)
      SolidQueueUi.dump_json(x)
    end

    def singularize(str, count)
      if count == 1 && str.respond_to?(:singularize) # rails
        str.singularize
      else
        str
      end
    end

    def clear_caches
      @strings = nil
      @locale_files = nil
      @available_locales = nil
    end

    def locale_files
      @locale_files ||= settings.locales.flat_map { |path|
        Dir["#{path}/*.yml"]
      }
    end

    def available_locales
      @available_locales ||= locale_files.map { |path| File.basename(path, ".yml") }.uniq
    end

    def find_locale_files(lang)
      locale_files.select { |file| file =~ /\/#{lang}\.yml$/ }
    end

    def search(jobset, substr)
      resultset = jobset.scan(substr).to_a
      @current_page = 1
      @count = @total_size = resultset.size
      resultset
    end

    def filtering(which)
      erb(:filtering, locals: {which: which})
    end

    def filter_link(jid, within = "retries")
      if within.nil?
        ::Rack::Utils.escape_html(jid)
      else
        "<a href='#{root_path}filter/#{within}?substr=#{jid}'>#{::Rack::Utils.escape_html(jid)}</a>"
      end
    end

    def display_tags(job, within = "retries")
      job.tags.map { |tag|
        "<span class='label label-info jobtag'>#{filter_link(tag, within)}</span>"
      }.join(" ")
    end

    # This view helper provide ability display you html code in
    # to head of page. Example:
    #
    #   <% add_to_head do %>
    #     <link rel="stylesheet" .../>
    #     <meta .../>
    #   <% end %>
    #
    def add_to_head
      @head_html ||= []
      @head_html << yield.dup if block_given?
    end

    def display_custom_head
      @head_html.join if defined?(@head_html)
    end

    def text_direction
      get_locale["TextDirection"] || "ltr"
    end

    def rtl?
      text_direction == "rtl"
    end

    # See https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
    def user_preferred_languages
      languages = env["HTTP_ACCEPT_LANGUAGE"]
      languages.to_s.downcase.gsub(/\s+/, "").split(",").map { |language|
        locale, quality = language.split(";q=", 2)
        locale = nil if locale == "*" # Ignore wildcards
        quality = quality ? quality.to_f : 1.0
        [locale, quality]
      }.sort { |(_, left), (_, right)|
        right <=> left
      }.map(&:first).compact
    end

    # Given an Accept-Language header like "fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4,ru;q=0.2"
    # this method will try to best match the available locales to the user's preferred languages.
    #
    # Inspiration taken from https://github.com/iain/http_accept_language/blob/master/lib/http_accept_language/parser.rb
    def locale
      @locale ||= begin
        matched_locale = user_preferred_languages.map { |preferred|
          preferred_language = preferred.split("-", 2).first

          lang_group = available_locales.select { |available|
            preferred_language == available.split("-", 2).first
          }

          lang_group.find { |lang| lang == preferred } || lang_group.min_by(&:length)
        }.compact.first

        matched_locale || "en"
      end
    end

    def get_locale
      strings(locale)
    end

    def t(msg, options = {})
      string = get_locale[msg] || strings("en")[msg] || msg
      if options.empty?
        string
      else
        string % options
      end
    end

    def sort_direction_label
      (params[:direction] == "asc") ? "&uarr;" : "&darr;"
    end


    def root_path
      "#{env["SCRIPT_NAME"]}/"
    end

    def current_path
      @current_path ||= request.path_info.gsub(/^\//, "")
    end

    # def current_status
    #   (workset.size == 0) ? "idle" : "active"
    # end

    def relative_time(time)
      stamp = time.getutc.iso8601
      %(<time class="ltr" dir="ltr" title="#{stamp}" datetime="#{stamp}">#{time}</time>)
    end

    SAFE_QPARAMS = %w[page direction]

    # Merge options with current params, filter safe params, and stringify to query string
    def qparams(options)
      stringified_options = options.transform_keys(&:to_s)

      to_query_string(params.merge(stringified_options))
    end

    def to_query_string(params)
      params.map { |key, value|
        SAFE_QPARAMS.include?(key) ? "#{key}=#{CGI.escape(value.to_s)}" : next
      }.compact.join("&")
    end

    def csrf_tag
      "<input type='hidden' name='authenticity_token' value='#{env[:csrf_token]}'/>"
    end


    def product_version
      "SolidQueueUi v#{SolidQueueUi::VERSION}"
    end

    def server_utc_time
      Time.now.utc.strftime("%H:%M:%S UTC")
    end

  end
end
