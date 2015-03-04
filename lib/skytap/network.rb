module Skytap
	class Network
		include Her::Model
		belongs_to :configuration
		collection_path ":configuration_url/networks"
	end
end