require 'active_record_union'

module Raap
  class Preloader
    class Association
      def initialize(vertex, loaded, index)
        @vertex = vertex
        @loaded = loaded # mutable from outside
        @index = index
        @scope = nil
      end

      def load!
        @loaded[klass.name] ||= []

        scope = build_scope

        unless scope
          mark_all_as_loaded!
          return
        end

        scope.each do |r|
          @loaded[klass.name] << r

          #TODO: we can index records for future scopes here insted of in #collected_ids
          #      (iterate through @vertex.outgoing_edges and collect keys)
          @vertex.each_edge { |e| associate_record!(r, e) }
        end

        mark_all_as_loaded!
      end

      private

      def associate_record!(record, edge)
        return if edge.skip_loading?

        if edge.scope_key == record.__scope_key
          find_owners(
            edge.join_key,
            edge.join_klass,
            record.send(edge.primary_key),
            edge.reflection,
            edge.through
          ).each do |owner|
            assoc = owner.association(edge.reflection.name)

            # TODO are duplicate records possible in collection????
            if edge.collection?
              # include? check is slow here. maybe make edges uniq by assoc_name and join_klassend_date
              assoc.target << record
            else
              assoc.target = record
            end
          end
        end
      end

      def find_owners(key, klass, value, reflection, through)
        if through
          find_owners_for_through_association(key, klass, value, reflection)
        else
          find_owners_for_association(key, klass, value, reflection)
        end
      end

      def find_owners_for_association(key, klass, value, reflection)
        @index.get(klass, key, value).map do |i|
          @loaded[klass.name][i]
        end
      end

      def find_owners_for_through_association(key, klass, value, reflection)
        # TODO: refactor
        through_reflection = reflection.through_reflection
        through_key = through_reflection.send :join_fk
        through_pkey = through_reflection.send :join_pk, through_reflection.klass
        through_klass = through_reflection.active_record

        find_owners_for_association(key, klass, value, reflection).flat_map do |middle_record|
          value = middle_record.send through_pkey
          find_owners_for_association(through_key, through_klass, value, through_reflection)
        end
      end

      def collected_ids
        @collected_ids ||= begin
          @vertex.each_edge.with_object({}) do |edge, result|
            recs = @loaded[edge.join_klass.name] || []
            ids = recs.map(&edge.join_key.to_sym).compact
            next if ids.empty?

            # TODO: see comment in #load!
            @index.index_by!(edge.join_klass, edge.join_key, recs)

            put_ids!(result, ids, edge)
          end
        end
      end

      def klass
        @vertex.klass
      end

      def build_scope
        scope = nil

        collected_ids.each do |scope_key, data_by_key|
          data_by_key.each do |key, scope_and_ids|
            reflection_scope = scope_and_ids[:scope]
            ids = scope_and_ids[:ids].to_a

            # TODO: steal scope builder from activerecord 5.1
            scope = if scope
              scope.union_all(scope_for key, ids, scope_key, reflection_scope)
            else
              scope_for(key, ids, scope_key, reflection_scope)
            end
          end
        end

        scope
      end

      def scope_for(key, ids, scope_key, reflection_scope = nil)
        klass
          .scope_for_association
          .select(
            klass.arel_table[Arel.star],
            "'#{scope_key}' as __scope_key"
          )
          .where(key => ids)
          .tap do |s|
          s.merge!(reflection_scope) if reflection_scope
        end
      end

      def put_ids!(store, ids, edge)
        store[edge.scope_key] ||= {}
        store[edge.scope_key][edge.primary_key] ||= {}
        store[edge.scope_key][edge.primary_key][:scope] = edge.scope
        store[edge.scope_key][edge.primary_key][:ids] ||= Set.new
        store[edge.scope_key][edge.primary_key][:ids].merge ids
      end

      # TODO: find a way to do this not so hacky
      # though it's clearly better performance-wise to iterate over fetched records
      # instead of indexing records and iterating over owners
      def mark_all_as_loaded!
        @vertex.each_edge do |e|
          mark_edge_as_loaded!(e)
        end
      end

      def mark_edge_as_loaded!(e)
        return if e.skip_loading?

        @loaded[e.load_klass.name].each do |r|
          assoc = r.association(e.reflection.name)
          assoc.loaded! unless assoc.loaded?
        end
      end
    end
  end
end
