module Her
  module Model
    module Associations
      class HasManyAssociation
        def using_collection_finders?
          !!@opts[:use_collection_finders]
        end

        alias_method :old_fetch, :fetch
        def fetch
          # Fetch the results using the original fetch method
          old_fetch_results = old_fetch

          # Re-add the primary key to the params if it was stripped out by where_from_collection
          params = @params.dup
          params[@collection_filter_key_name] = @collection_filter_key_value if @collection_filter_key_value

          # Add the parent's foreign key to the params so URLs work for objects that don't get them from the server
          inverse_of = "#{@opts[:inverse_of] || @parent.singularized_resource_name}_id"
          params[inverse_of.to_sym] = @parent.id

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
          #TODO - DRY this up? the first line is the only one that's at all different from the Relation method
          parent_key = @parent.class.primary_key
          @collection_filter_key_name = parent_key
          @collection_filter_key_value = args.delete(parent_key)
          normal_where(args.reject {|key| key == parent_key})
        end

        alias_method :normal_find, :find
        def find(id)
          using_collection_finders? ? find_from_collection(id) : normal_find(id)
        end

        def find_from_collection(id)
          result = where({id: id}.merge(params))
          result.empty? ? nil : result.first
        end
      end
    end
  end
end