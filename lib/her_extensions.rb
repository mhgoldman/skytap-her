module Her
	module Model
		class Relation
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
		end

		module Associations
			# Can add methods here and have them be at the level of association
			def use_lazy_finders(setting=true)
				@use_lazy_finders = setting
			end

			class HasManyAssociation
				#For has_many associations, inject the parent_id into the attributes of the collection members so that they can actually have URLs
				alias_method :old_fetch, :fetch
				def fetch
					old_fetch
          inverse_of = @opts[:inverse_of] || @parent.singularized_resource_name
					super.tap do |o|
            o.each { |entry| entry.send("#{inverse_of}_id=", @parent.id) }            
          end
       	end

       	# TODO -- this logic should only be used for certain models...
       	alias_method :old_where, :where
				
				def lazy_where(params={})
					all.fetch.select {|pt| pt['id'].to_s == params[:id].to_s}
				end

				def where(params={})
					@use_lazy_finders ? lazy_where(params) : old_where(params)
				end

				alias_method :old_find, :find

				#TODO Haven't tested this yet and doubt it works
				def lazy_find(*ids)
					params = @params.merge(ids.last.is_a?(Hash) ? ids.pop : {})
	        ids = Array(params[@parent.primary_key]) if params.key?(@parent.primary_key)

      	  results = ids.flatten.compact.uniq.map do |id|
    	    	result = where({@parent.primary_key: id}.merge(params))
  	      	result.empty? ? nil : result.first
	        end
				end

				#TODO: RUH-ROH! This probably won't work because the method signatures don't work.
				#Make lazy_find accept *params 
				def find(*ids)
					@use_lazy_finders ? lazy_find(params) : old_find(params)
				end
			end
		end

	  module Attributes		
	  	#Allow deletion of attributes coming from the server that we don't want visible on the object
			def delete_attribute(key)
				@attributes.delete(key)
			end
		end
	end
end
