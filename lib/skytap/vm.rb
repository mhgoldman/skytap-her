module Skytap
	class VM
		include Her::Model
		belongs_to :configuration
		collection_path ":configuration_url/vms" # This makes creating a new VM post to /config/[id] and also sets resource_path which means puts/deletes go to /config/[id]/vms/[id]

		after_initialize do
		 	self.configuration_id = self.configuration_url.split('/').last  # This makes the association work when doing Configuration.find
	 	end
	end
end