module FastPreloader
  module ActiveRecord
    module RelationExt
      def use_fast_preloader(enabled = true)
        @use_preloader_enabled = enabled
        self
      end

      def exec_queries(&block)
        if fast_preloader_enabled?
          @records = eager_loading? ? find_with_associations.freeze : @klass.find_by_sql(arel, bound_attributes, &block).freeze

          preload = preload_values
          preload += includes_values unless eager_loading?

          FastPreloader::Preloader.new.preload(@records, preload)

          @records.each(&:readonly!) if readonly_value

          @loaded = true
          @records
        else
          super
        end
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

    ::ActiveRecord::Relation.prepend RelationExt
  end
end
