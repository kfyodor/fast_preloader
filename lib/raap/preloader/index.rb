module Raap
  class Preloader
    class Index
      def initialize
        @index = {}
      end

      def get(klass, key, val)
        klass = klass.name
        key   = key.to_s

        @index[klass] && @index[klass][key] && @index[klass][key][val] || []
      end

      def get_one(klass, key, val)
        i = get(klass, key, val)
        i && i.first
      end

      def index_by!(klass, key, records)
        return if @index[klass.name] && @index[klass.name].keys.include?(key.to_s) # already indexed

        records.each.with_index do |rec, idx|
          add!(klass, key, idx, rec)
        end
      end

      def inspect
        @index.inspect
      end

      def add!(klass, key, idx, rec)
        k     = rec.send(key)
        klass = klass.name
        key   = key.to_s

        @index[klass] ||= {}
        @index[klass][key] ||= {}

        if k
          @index[klass][key][k] ||= []
          @index[klass][key][k] << idx
        end
      end
    end
  end
end
