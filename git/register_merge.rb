require 'active_record'

puts 'Registering merge'

load 'config.rb'
load 'lib/common.rb'

ensure_dir GIT_REPO_HOME do
	ActiveRecord::Base.establish_connection(
		:adapter => 'sqlite3',
		:database => '.visualMerge/visualMerge.db'		
	)

	register_merge GIT_REPO_HOME	
end
