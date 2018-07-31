module Raap
  module ActiveRecord
    ::ActiveRecord::Relation.prepend Module.new do
      def raap(enabled = true)
        @raap_enabled = enabled
        self
      end

      def exec_queries(&block)
        if raap_enabled?
          @records = eager_loading? ? find_with_associations.freeze : @klass.find_by_sql(arel, bound_attributes, &block).freeze

          preload = preload_values
          preload += includes_values unless eager_loading?

          Raap::Preloader.new.preload(@records, preload)

          @records.each(&:readonly!) if readonly_value

          @loaded = true
          @records
        else
          super
        end
      end

      private

      def raap_enabled?
        if defined?(@raap_enabled)
          @raap_enabled
        else
          @klass.raap_enabled?
        end
      end
    end
  end
end
