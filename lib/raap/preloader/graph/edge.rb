module Raap
  class Preloader
    class Graph
      class Edge
        attr_reader :from, :to, :reflection

        DEFAULT_SCOPE_KEY = '_'.freeze

        def initialize(from, to, reflection, skip_loading: false)
          @from = from
          @to = to
          @reflection = reflection

          # indicates if an edge is used for fetchng middle records
          # for through assoc
          @skip_loading = skip_loading
        end

        def ignore?
          @ignore
        end

        def join_klass
          @from.klass
        end

        def load_klass
          if through
            @reflection.active_record
          else
            join_klass
          end
        end

        def skip_loading?
          @skip_loading
        end

        def klass
          @to.klass
        end

        # TODO: join_pk and join_fk are rails 5.1 only
        def primary_key
          reflection_for_key.send(:join_pk, klass)
        end

        def join_key
          reflection_for_key.send(:join_fk)
        end

        def scope
          if @reflection.has_scope?
            @reflection.scope_for(klass)
          end
        end

        def collection?
          @reflection.collection?
        end

        def scope_key
          if @reflection.has_scope?
            "#{join_klass.name}_#{@reflection.name}"
          else
            DEFAULT_SCOPE_KEY
          end
        end

        def through
          @reflection.options[:through]
        end

        def inspect
          "#{from.klass}->#{to.klass}"
        end

        private

        def reflection_for_key
          through ? @reflection.source_reflection : @reflection
        end
      end
    end
  end
end
