module Raap
  class Preloader
    class Graph
      class Root < Vertex
        def initialize(klass = self)
          @outgoing_edges = []
          @incoming_edges = []
          @klass = klass
        end

        def root?
          true
        end
      end
    end
  end
end
