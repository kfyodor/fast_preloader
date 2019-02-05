module FastPreloader
  module ActiveRecord
    module ExecQueryRelationExt
      def exec_queries(&block)
        if fast_preloader_enabled?
          skip_query_cache_if_necessary do
            @records =
              if eager_loading?
                apply_join_dependency do |relation, join_dependency|
                  if ActiveRecord::NullRelation === relation
                    []
                  else
                    relation = join_dependency.apply_column_aliases(relation)
                    rows = connection.select_all(relation.arel, "SQL")
                    join_dependency.instantiate(rows, &block)
                  end.freeze
                end
              else
                klass.find_by_sql(arel, &block).freeze
              end

            preload = preload_values
            preload += includes_values unless eager_loading?

            FastPreloader::Preloader.new.preload(@records, preload)

            @records.each(&:readonly!) if readonly_value

            @loaded = true
            @records
          end
        else
          super
        end
      end
    end

    ::ActiveRecord::Relation.prepend ExecQueryRelationExt
  end
end
