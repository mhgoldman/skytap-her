$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

ENV['HER_USER'] = ''
ENV['HER_PASS'] = ''

require 'her'

module Skytap
	autoload :Configuration, 'skytap/configuration'
	autoload :Network, 'skytap/network'
	autoload :Project, 'skytap/project'
	autoload :Template, 'skytap/template'
	autoload :VM, 'skytap/vm'
	autoload :ProjectTemplate, 'skytap/project_template'
end

require 'httplog'
HttpLog.options[:log_headers] = true

require 'her_extensions/her/model/class_methods'
require 'her_extensions/her/model/relation'
require 'her_extensions/her/model/associations/has_many_association'
require 'setup'

# v = Skytap::VM.find(4685072, configuration_id: 3442128)
# v.name = 'THE NAME CHANGE GOES HERE 6'
# v.save

# #c = v.configuration
# c = Skytap::Configuration.find(3442128)
# puts c.class
# puts c.name
# puts c.vms

# Adding a single-VM template to a config. (Note: this will do something weird if there were multiple VMs in the template...)
# v2 = Skytap::VM.new(configuration_id: 3442128, template_id: 531869)
# v2.save
# puts v2.id

# c = Skytap::Configuration.new(template_id: 531869)
# c.save
# puts c.id
# c.runstate = 'running'
# c.save

# v = Skytap::VM.find(4702040, configuration_id: 3454828)
# v.runstate = 'suspended'
# v.save

# t  = Skytap::Template.new
# t.configuration_id = 3454828
# t.youcanignoerthis = 42
# t.name = "THAT TEMPLATE I MADE, AGAIN!"
# t.save
# puts t.id

# c = Skytap::Configuration.find(3454828)
# n = c.networks.first
# n.name = 'foonet'
# n.save

# With Her, how to add a template to a project?
