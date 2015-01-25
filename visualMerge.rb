#!/usr/bin/env ruby

require 'rubygems'
require 'active_record'
require 'json'

load 'lib/common.rb'
load 'config.rb'

def init_db

	ActiveRecord::Base.establish_connection(
		:adapter => 'sqlite3',
		:database => 'visualMerge.db'		
	)

	ActiveRecord::Schema.define do
		create_table :merges, :force => true do |t|
			t.column :old_head, :string, :null => false
			t.column :new_head, :string, :null => false
			
			t.timestamps
		end
	end

end

action = ARGV[0]

case action
when 'init'
	run_shell 'mkdir .visualMerge', '.'
	
	run_shell "rm '#{GIT_REPO_HOME}/.git/hooks/post-merge'", '.'
	run_shell "ln -s '#{Dir.pwd}/.visualMerge/git/post-merge', '#{GIT_REPO_HOME}/.git/hooks/post-merge'", '.'
	
	ensure_dir '.visualMerge' do
		init_db	
	end
	
end