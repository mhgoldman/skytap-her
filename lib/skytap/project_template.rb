module Her
	module Model
		class Relation
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

module Skytap
	class ProjectTemplate
		include Her::Model
		belongs_to :project
		belongs_to :template

		collection_path 'projects/:project_id/templates' #This is where new items will be POSTed to

		#before_save do
			#assign_attributes(id: self.template_id)
		#end

		after_save do
			# need template_id so that calling .template will work
			assign_attributes(template_id: self.id)

			# remove superfluous url attribute, which points to the main template URL and confuses things
			delete_attribute(:url)
		end

		after_find do
			# need template_id so that calling .template will work
			assign_attributes(template_id: self.id)

			# remove superfluous url attribute, which points to the main template URL and confuses things
			delete_attribute(:url)
		end


		#proj.project_templates.first now works.
		#ProjectTemplate.create(project_id: xyz, id: zyx) (where id = template id) works.
		#Skytap::ProjectTemplate.find(project_id: 37878, id: 534113) now works (but only because I redefined .find)
		#p.project_templates.where(id: 534113) works.

		# UNFIXED PROBLEMS:

		#Skytap::ProjectTemplate.where(project_id: 37878, id: 534113) DOES NOT work because it's trying to GET the resource
		#p.project_templates.find(534113) DOES NOT work because it's trying to GET the resource
		#project_template.destroy works, but doesn't update the object or its associations. is that the standard behavior?

		def self.find(args)
			pts = self.all(project_id: args[:project_id]).select {|pt| pt['id'].to_s == args[:id].to_s}
			pts ? pts.first : nil
		end

		# Her assumes when id is being set, the record must already exist, and so it wants to PUT instead of POST.
		# So we provide alternative logic for determining whether this is a new or existing record.
		def new?
			!@saved
		end

		after_save do
			@saved = true
		end

		# We're in pretty good shape now. What about GET?
	end
end