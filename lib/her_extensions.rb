module Her
	module Model
		module ClassMethods
			def use_lazy_finders(setting=true)
				@use_lazy_finders = setting
			end

			def using_lazy_finders?
				!!@use_lazy_finders
			end
		end

	  module Attributes		
	  	# Allow deletion of attributes coming from the server that we don't want visible on the object
			def delete_attribute(key)
				@attributes.delete(key)
			end
		end

		class Relation
			def using_lazy_finders?
				@parent.using_lazy_finders?
			end

			# Inject search params into the resulting objects if they're not already in there
			alias_method :old_fetch, :fetch
			def fetch
				results = old_fetch
        0.upto(results.length-1) do |i|
          @params.each do |k,v|
            results[i].attributes[k] = v unless results[i].attributes[k]
          end
        end
				results
			end

			alias_method :old_where, :where
			def where(args)
				using_lazy_finders? ? lazy_where(args) : old_where(args)
			end

			def lazy_where(args)
				parent_key = @parent.primary_key
				all(args.reject {|key| key == parent_key}).select {|pt| pt[parent_key.to_s].to_s == args[parent_key].to_s}
			end

			alias_method :old_find, :find
			def find(*ids)
				using_lazy_finders? ? lazy_find(*ids) : old_find(*ids)
			end

			def lazy_find(*ids)
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
				def using_lazy_finders?
					!!@opts[:use_lazy_finders]
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

       	alias_method :old_where, :where
       	def where(args)
       		using_lazy_finders? ? lazy_where(args) : old_where(args)
       	end

				def lazy_where(args)
					all.fetch.select {|pt| pt['id'].to_s == args[:id].to_s}
				end

				alias_method :old_find, :find
				def find(id)
					using_lazy_finders? ? lazy_find(id) : old_find(id)
				end

				def lazy_find(id)
					result = where({id: id}.merge(params))
					result.empty? ? nil : result.first
				end
			end
		end
	end
end