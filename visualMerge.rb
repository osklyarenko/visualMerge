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

	register_merge GIT_REPO_HOME	
end

action = ARGV[0]

case action
when 'init'
	run_shell 'mkdir .visualMerge', '.'
	
	run_shell "rm -f '.visualMerge/visualMerge.db'", GIT_REPO_HOME
	run_shell "rm -f '.git/hooks/post-merge'", GIT_REPO_HOME
	run_shell "rm -f '.git/hooks/common,rb'", GIT_REPO_HOME

	run_shell "ln -s '#{Dir.pwd}/git/post-merge' post-merge", "#{GIT_REPO_HOME}/.git/hooks"	
	run_shell "ln -s '#{Dir.pwd}/lib/common.rb' common.rb", "#{GIT_REPO_HOME}/.git/hooks"	
	
	config_script = <<-EOS
		#!/bin/bash
		echo "VISUAL_MERGE_HOME = '#{Dir.pwd}'" > .git/hooks/visual_merge_config.rb
	EOS
	run_shell config_script, GIT_REPO_HOME
	
	ensure_dir '.visualMerge' do
		init_db	
	end
	
end