module FastPreloader
  class Preloader
    class Graph
      class Edge
        attr_reader :from, :to, :reflection

        DEFAULT_SCOPE_KEY = '_'.freeze

        def initialize(from, to, reflection, through: nil, skip_loading: false)
          @from = from
          @to = to
          @reflection = reflection

          # we need to keep a link to the parent edge here
          @through = through
          check_through!

          # indicates if an edge is used for fetchng middle records
          # in through association
          @skip_loading = skip_loading
        end

        def join_klass
          @from.klass
        end

        def load_klass
          if through?
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
          @through
        end

        def through?
          !@through.nil?
        end

        def inspect
          "#{from.klass}->#{to.klass}"
        end

        def hash
          @from.klass.hash ^ @to.klass.hash ^ @reflection.name.hash ^ @skip_loading.hash
        end

        def ==(other)
          from.klass == other.from.klass and
          to.klass == other.to.klass and
          reflection.name == other.reflection.name and
          skip_loading? == other.skip_loading?
        end

        alias eql? ==

        private

        def check_through!
          if @through && !@reflection.options[:through]
            raise "#{inspect} is not a \"through\" association"
          end
        end

        def reflection_for_key
          through ? @reflection.source_reflection : @reflection
        end
      end
    end
  end
end
