module FastPreloader
  class Preloader
    autoload :Index,       'fast_preloader/preloader/index'
    autoload :Graph,       'fast_preloader/preloader/graph'
    autoload :Association, 'fast_preloader/preloader/association'

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

    def compile_associations(graph, root_klass, associations, parent_reflection = nil)
      Array.wrap(associations).flat_map do |assoc|
        case assoc
        when Hash
          compile_hash(graph, root_klass, assoc, parent_reflection)
        when Symbol, String
          compile_one(graph, root_klass, assoc.to_sym, parent_reflection)
        end
      end
    end

    def compile_hash(graph, klass, associations, parent_reflection)
      associations.flat_map do |parent, child|
        edge = compile_one(graph, klass, parent, parent_reflection)

        Array.wrap(child).flat_map do |assoc|
          compile_associations(graph, edge.klass, assoc, edge.reflection)
        end
      end
    end

    def compile_one(graph, klass, association, parent_reflection)
      reflection = klass._reflect_on_association(association)

      unless reflection
        Rails.logger.warn "[FastPreloader] Association #{association} is not defined on #{klass}, skipping..."
        return
      end

      if reflection.options[:through]
        compile_through_association(graph, reflection, parent_reflection)
      else
        graph.add_edge(parent_reflection, reflection)
      end
    end

    # TODO: test nested throughs
    def compile_through_association(graph, reflection, parent_reflection, skip_loading: false)
      through_reflection = reflection.through_reflection

      if through_reflection.options[:through]
        # nested through
        through_edge = compile_through_association(
          graph,
          through_reflection,
          parent_reflection,
          skip_loading: true
        )

        graph.add_edge(through_reflection, reflection, through: through_edge)
      else
        through_edge = graph.add_edge(parent_reflection, through_reflection, skip_loading: true)
        graph.add_edge(through_reflection, reflection, through: through_edge, skip_loading: skip_loading)
      end
    end

    def load_associations!(graph, root_klass, records, preload_scope)
      index = Index.new
      index.index_by!(root_klass, root_klass.primary_key, records)

      # puts "====== DEBUG GRAPH ======"
      # graph.tsort.each do |v|
      #   puts v.inspect
      # end
      # puts "========================="

      graph.tsort.each_with_object({ root_klass.name => records }) do |v, loaded|
        load_association!(v, index, loaded, preload_scope)
      end
    end

    def load_association!(vertex, index, loaded, preload_scope)
      Association.new(vertex, loaded, index).load!
    end
  end
end
