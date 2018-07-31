module Raap
  class Graph
    class Edge
      attr_reader :from, :to, :assoc

      DEFAULT_SCOPE_KEY = '_'.freeze

      def initialize(from, to, assoc, skip_preloading: false)
        @from = from
        @to = to
        @assoc = assoc

        # indicates if an edge is used only for
        # correct tsort in presence of through assocs
        @skip_preloading = skip_preloading
      end

      def ignore?
        @ignore
      end

      def join_klass
        @from.klass
      end

      def klass
        @to.klass
      end

      def primary_key
        @assoc.send(:join_pk, klass)
      end

      def join_key
        @assoc.send(:join_fk)
      end

      def scope
        if @assoc.has_scope?
          @assoc.scope_for(klass)
        end
      end

      def collection?
        @assoc.collection?
      end

      def scope_key
        @assoc.has_scope? ? "#{join_klass.name}_#{@assoc.name}" : DEFAULT_SCOPE_KEY
      end

      def through
        @assoc.options[:through]
      end

      def inspect
        "#{from.klass}->#{to.klass}"
      end
    end
  end
end
