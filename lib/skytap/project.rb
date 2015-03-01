module Skytap
	class Project
		include Her::Model
		has_many :configurations
		has_many :project_templates, class_name: 'ProjectTemplate', path: '/templates'
	end
end