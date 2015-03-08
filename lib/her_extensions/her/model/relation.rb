module Her
  module Model
    class Relation
      def using_collection_finders?
        @parent.using_collection_finders?
      end

      alias_method :old_fetch, :fetch
      def fetch
        # Fetch the results using the original fetch method
        old_fetch_results = old_fetch

        # Re-add the primary key to the params if it was stripped out by where_from_collection
        params = @params.dup
        params[@collection_filter_key_name] = @collection_filter_key_value if @collection_filter_key_value

        # Inject the necessary params in the objects that were previously returned
        results = inject_params_into(old_fetch_results, params)

        # Filter by the primary key if where_from_collection was used
        if @collection_filter_key_value
          results.select {|pt| pt[@collection_filter_key_name.to_s].to_s == @collection_filter_key_value.to_s} 
        else
          results
        end
      end

      private def inject_params_into(results, params)
        0.upto(results.length-1) do |i|
          path = params.include?(results[i].class.primary_key) ? results[i].class.resource_path : results[i].class.collection_path
          params.each do |k,v|
            results[i].attributes[k] = v if (!results[i].attributes[k] && path.match(":_?#{k}"))
          end
        end
        results
      end

      alias_method :normal_where, :where
      def where(args)
        using_collection_finders? ? where_from_collection(args) : normal_where(args)
      end

      def where_from_collection(args)
        # If caller is filtering by primary key (e.g. id), exclude that from the where() call. 
        # Otherwise, Her will try to get the resource by id.
        # We save the primary key name and value so that fetch() can filter it out later.

        parent_key = @parent.primary_key
        @collection_filter_key_name = parent_key
        @collection_filter_key_value = args.delete(parent_key)
        results = normal_where(args.reject {|key| key == parent_key})
      end

      alias_method :normal_find, :find
      def find(*ids)
        using_collection_finders? ? find_from_collection(*ids) : normal_find(*ids)
      end

      def find_from_collection(*ids)
        params = @params.merge(ids.last.is_a?(Hash) ? ids.pop : {})
        ids = Array(params[@parent.primary_key]) if params.key?(@parent.primary_key)
        results = ids.flatten.compact.uniq.map do |id|
          where({@parent.primary_key => id}.merge(params)).first
        end
        ids.length > 1 || ids.first.kind_of?(Array) ? results : results.first
      end
    end
  end
end