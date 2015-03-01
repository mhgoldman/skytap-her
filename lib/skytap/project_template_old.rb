module Skytap
	class ProjectTemplateOld
		include Her::Model

		belongs_to :project

		# Destroy -> DELETE
		# /templates/:id -- get/update/delete the template itself

		collection_path '/projects/:project_id/templates' #GET - List templates in this project.

		# WARNING, HACKY ALERT! collection_path actually sets resource_path, so you have to call collection_path THEN resource_path
		resource_path '/templates/:id' #GET/PUT - Get/update the template itself

		# if you set resource_path, then POSTs start going to resource_path instead of collection_path... wtf?

		def new?
			!@saved
		end

		after_save do
			@saved = true
		end

		def request_path
			path = new? ? self.class.collection_path : self.class.resource_path
			self.class.build_request_path(path, attributes.dup)

puts "GOT the request path #{request_path}"
request_path
			# path_tokens = path.split('/')
			# new_path_tokens = path_tokens.map do |token|
			# 	if token.start_with?(':')
			# 		attr_name = token[1..-1]
			# 		attributes[attr_name]
			# 	else
			# 		token
			# 	end
			# end
			# new_path_tokens.join('/')
		end
	end
end