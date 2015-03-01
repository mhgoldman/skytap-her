module Skytap
	class Configuration
		include Her::Model
		has_many :vms, class_name: 'VM'
		#NOTE: Skytap API doesn't link Configurations back to containing Projects, so can't associate from Config back to Project
	end
end