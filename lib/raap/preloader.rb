require 'index'
require 'graph'
require 'association'

module Raap
  class Preloader

    autoload :Index, 'raap/index'
    autoload :Graph, 'raap/graph'
    autoload :Association, 'raap/association'

    def preload(records, associations, preload_scope = nil)
      records = Array.wrap(records).compact
      klass   = records.first.class
      graph   = Graph.new(klass)

      if records.any?
        compile_associations(graph, klass, associations)
        load_associations!(graph, klass, records, preload_scope)
      else
        []
      end
    end

    private

    def compile_associations(graph, root_klass, associations, parent_node = nil)
      Array.wrap(associations).flat_map do |assoc|
        case assoc
        when Hash
          compile_hash(graph, root_klass, assoc, parent_node)
        when Symbol, String
          compile_one(graph, root_klass, assoc.to_sym, parent_node)
        end
      end
    end

    def compile_hash(graph, klass, associations, parent_node)
      associations.flat_map do |parent, child|
        reflection = klass._reflect_on_association(parent)
        parent_klass = reflection.klass

        graph.add_edge(parent_node, reflection)

        Array.wrap(child).flat_map do |assoc|
          compile_associations(graph, parent_klass, assoc, reflection)
        end
      end
    end

    def compile_one(graph, klass, association, parent_node)
      child = klass._reflect_on_association(association)
      graph.add_edge(parent_node, child)
    end

    def load_associations!(graph, root_klass, records, preload_scope)
      index = Index.new
      index.index_by!(root_klass, root_klass.primary_key, records)

      graph.tsort.each_with_object({ root_klass.name => records }) do |v, loaded|
        load_association!(v, index, loaded, preload_scope)
      end
    end

    def load_association!(vertex, index, loaded, preload_scope)
      Association.new(vertex, loaded, index).load!
    end
  end
end
