module Raap
  module ActiveRecord
    if defined?(::ActiveRecord)
      case active_record_version
      when '5.1'
        require 'active_record/active_record51.rb'
      else
        raise "[Raap] ActiveRecord #{active_record_version} is not supported."
      end

      ::ActiveRecord::Base.extend Module.new do
        def raap(enabled = true)
          @raap_enabled = enabled
        end

        def raap_enalbed?
          if defined?(@raap_enabled)
            @raap_enabled
          else
            Raap.enabled?
          end
        end
      end
    else
      raise "[Raap] ActiveRecord could not be found"
    end

    private

    def active_record_version
      [::ActiveRecord::VERSION::MAJOR, ::ActiveRecord::VERSION::MINOR].join('.')
    end
  end
end
