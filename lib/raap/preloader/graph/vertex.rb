require 'set'

module Raap
  class Preloader
    class Graph
      class Vertex
        attr_accessor :incoming_edges, :outgoing_edges, :klass

        def initialize(klass)
          @klass = klass
          @incoming_edges = Set.new
          @outgoing_edges = Set.new
        end

        def inspect
          "#{klass.name}: in=#{incoming_edges}, out=#{outgoing_edges}"
        end

        def root?
          false
        end

        def to_s
          inspect
        end

        def each_edge(&block)
          @incoming_edges.each &block
        end
      end
    end
  end
end
