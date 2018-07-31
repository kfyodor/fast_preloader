module Raap
  module ActiveRecord
    def self.init
      active_record_version = [
        ::ActiveRecord::VERSION::MAJOR,
        ::ActiveRecord::VERSION::MINOR
      ].join('.')

      case active_record_version
      when '5.1'
        require 'raap/active_record/active_record51.rb'
      else
        raise "[Raap] ActiveRecord #{active_record_version} is not supported."
      end

      ::ActiveRecord::Base.include BaseExt
    end

    module BaseExt
      extend ActiveSupport::Concern

      included do
        class_attribute :_raap
        extend ClassMethods
      end

      module ClassMethods
        def raap(enabled = true)
          self._raap = enabled
        end

        def raap_enabled?
          if self._raap.nil?
            Raap.enabled?
          else
            self._raap
          end
        end
      end
    end
  end
end
