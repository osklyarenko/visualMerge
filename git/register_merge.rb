require 'active_record'

load '.git/hooks/common.rb'

puts 'Registering merge'

ActiveRecord::Base.establish_connection(
	:adapter => 'sqlite3',
	:database => '.git/hooks/visualMerge.db'		
)

register_merge Dir.pwd