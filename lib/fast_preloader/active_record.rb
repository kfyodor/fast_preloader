module FastPreloader
  module ActiveRecord
    def self.init
      active_record_version = [
        ::ActiveRecord::VERSION::MAJOR,
        ::ActiveRecord::VERSION::MINOR
      ].join('.')

      case active_record_version
      when '5.1'
        require 'fast_preloader/active_record/active_record51.rb'
      else
        raise "[FastPreloader] ActiveRecord #{active_record_version} is not supported."
      end

      ::ActiveRecord::Base.include BaseExt
    end

    module BaseExt
      extend ActiveSupport::Concern

      included do
        class_attribute :_fast_preloader
        extend ClassMethods
      end

      module ClassMethods
        def fast_preloader(enabled = true)
          self._fast_preloader = enabled
        end

        def use_fast_preloader(enabled = true)
          all.use_fast_preloader(enabled)
        end

        def fast_preloader_enabled?
          if self._fast_preloader.nil?
            FastPreloader.enabled?
          else
            self._fast_preloader
          end
        end
      end
    end
  end
end
