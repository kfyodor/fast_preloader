module FastPreloader
  module ActiveRecord
    def self.init
      ::ActiveRecord::Relation.prepend RelationExt # TODO: check whether it depends on AR version

      active_record_version = [
        ::ActiveRecord::VERSION::MAJOR,
        ::ActiveRecord::VERSION::MINOR
      ].join('.')

      case active_record_version
      when '5.1'
        require 'fast_preloader/active_record/active_record51.rb'
      when '5.2'
        require 'fast_preloader/active_record/active_record52.rb'
      else
        raise "[FastPreloader] ActiveRecord #{active_record_version} is not supported."
      end

      ::ActiveRecord::Base.include BaseExt
    end

    module RelationExt
      def use_fast_preloader(enabled = true)
        @use_preloader_enabled = enabled
        self
      end

      private

      def fast_preloader_enabled?
        if defined?(@use_preloader_enabled)
          @use_preloader_enabled
        else
          @klass.fast_preloader_enabled?
        end
      end
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
