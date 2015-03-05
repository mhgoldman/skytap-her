module Her
	module Model
		module ClassMethods
			def use_collection_finders(setting=true)
				@use_collection_finders = setting
			end

			def using_collection_finders?
				!!@use_collection_finders
			end
		end

		class Relation
			def using_collection_finders?
				@parent.using_collection_finders?
			end

			# Inject search params in the resource path into the resulting objects if they're not already in there
			alias_method :old_fetch, :fetch
			def fetch
				results = old_fetch
        0.upto(results.length-1) do |i|
        	path = @params.include?(results[i].class.primary_key) ? results[i].class.resource_path : results[i].class.collection_path
          @params.each do |k,v|
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
				parent_key = @parent.primary_key
				all(args.reject {|key| key == parent_key}).select {|pt| pt[parent_key.to_s].to_s == args[parent_key].to_s}
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

		module Associations
			class HasManyAssociation
				def using_collection_finders?
					!!@opts[:use_collection_finders]
				end

				#For has_many associations, inject the parent_id into the attributes of the collection members so that they can actually have URLs
				alias_method :old_fetch, :fetch
				def fetch
					old_fetch
          inverse_of = @opts[:inverse_of] || @parent.singularized_resource_name
					super.tap do |o|
            o.each { |entry| entry.send("#{inverse_of}_id=", @parent.id) }            
          end
       	end

       	alias_method :normal_where, :where
       	def where(args)
       		using_collection_finders? ? where_from_collection(args) : normal_where(args)
       	end

				def where_from_collection(args)
					parent_key = @parent.class.primary_key
					all(args.reject {|key| key == parent_key}).select {|pt| pt[parent_key.to_s].to_s == args[parent_key].to_s}
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