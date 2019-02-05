module FastPreloader
  module ActiveRecord
    module ExecQueryRelationExt
      def exec_queries(&block)
        if fast_preloader_enabled?
          @records =
            if eager_loading?
              find_with_associations do |relation, join_dependency|
                if ActiveRecord::NullRelation === relation
                  []
                else
                  rows = connection.select_all(relation.arel, "SQL", relation.bound_attributes)
                  join_dependency.instantiate(rows, &block)
                end.freeze
              end
            else
              klass.find_by_sql(arel, bound_attributes, &block).freeze
            end

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
    end

    ::ActiveRecord::Relation.prepend ExecQueryRelationExt
  end
end
