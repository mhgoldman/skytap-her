module Skytap
	class ProjectTemplate
		include Her::Model
		belongs_to :project
		belongs_to :template
		use_collection_finders
		
		collection_path 'projects/:project_id/templates' #This is where new items will be POSTed to

		after_save :mark_saved, :fix_attributes
		after_find :fix_attributes

		# Her assumes when id is being set, the record must already exist, and so it wants to PUT instead of POST.
		# So we provide alternative logic for determining whether this is a new or existing record.
		def new?
			!@saved
		end

		private

		def fix_attributes
			self.template_id = self.id
		end

		def mark_saved
			@saved = true
		end
	end
end