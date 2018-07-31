require 'tsort'
require 'set'

module Raap
  class Graph
    include TSort

    autoload :Edge, 'raap/graph/edge'
    autoload :Vertex, 'raap/graph/vertex'

    attr_reader :root, :vertices

    def initialize(root_klass)
      @root = Root.new(root_klass)
      @vertices = {}
    end

    def add_edge(parent_reflection = nil, child_reflection)
      parent_vertex =
        if parent_reflection
          klass = parent_reflection.klass
          @vertices[klass.name] ||= Vertex.new(parent_reflection.klass)
        else
          @root
        end

      child_klass = child_reflection.klass
      child_vertex = @vertices[child_klass.name] ||= Vertex.new child_klass

      edge = Edge.new(parent_vertex, child_vertex, child_reflection)
      edge.from.outgoing_edges << edge
      edge.to.incoming_edges   << edge

      edge
    end

    def empty?
      @vertices.empty?
    end

    def inspect
      "<Raap::Graph vertices=#{@vertices.values}"
    end

    def each(&block)
      @vertices.values.each(&block)
    end

    def tsort
      super.drop(1)
    end

    private

    def tsort_each_node(&b)
      ([@root] + @vertices.values).each(&b)
    end

    def tsort_each_child(n, &b)
      (n.incoming_edges.map(&:from)).each(&b)
    end
  end
end