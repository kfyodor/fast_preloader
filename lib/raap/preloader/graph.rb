require 'tsort'
require 'set'

module Raap
  class Preloader
    class Graph
      autoload :Edge, 'raap/preloader/graph/edge'
      autoload :Vertex, 'raap/preloader/graph/vertex'
      autoload :Root, 'raap/preloader/graph/root'

      include TSort

      attr_reader :root, :vertices

      def initialize(root_klass)
        @root = Root.new(root_klass)
        @vertices = {}
      end

      def add_edge(parent_reflection = nil, child_reflection, **edge_options)
        parent_vertex =
          if parent_reflection
            parent_key = "#{parent_reflection.klass.name}0"
            @vertices[parent_key] ||= Vertex.new(parent_reflection.klass)
          else
            @root
          end

        child_level = self_reference?(parent_reflection, child_reflection, **edge_options) ? 1 : 0
        child_key = "#{child_reflection.klass.name}#{child_level}"
        child_vertex = @vertices[child_key] ||= Vertex.new child_reflection.klass, child_level

        Edge.new(parent_vertex, child_vertex, child_reflection, **edge_options).tap do |edge|
          edge.from.outgoing_edges << edge
          edge.to.incoming_edges << edge
        end
      end

      def inspect
        "<Raap::Graph vertices=#{@vertices.values}"
      end

      def tsort
        super.drop(1)
      end

      private

      def self_reference?(parent, child, **opts)
        if parent
          through = opts[:through]
          (parent.klass == child.klass) || (through && through.join_klass == child.klass)
        end
      end

      def tsort_each_node(&b)
        ([@root] + @vertices.values).each(&b)
      end

      def tsort_each_child(n, &b)
        (n.incoming_edges.map(&:from)).each(&b)
      end
    end
  end
end
