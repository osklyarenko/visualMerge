#!/usr/bin/env ruby

require 'rubygems'
require 'active_record'
require 'json'

load 'lib/common.rb'
load 'config.rb'

def init_db
	
	ActiveRecord::Schema.define do
		create_table :merges, :force => true do |t|
			t.column :old_head, :string, :null => false
			t.column :new_head, :string, :null => false
			
			t.timestamps
		end
	end

	register_merge GIT_REPO_HOME	
end

def git_changed_files(repo)
	merge = Merge.last

	return nil unless merge
	return [] if merge.old_head == merge.new_head

	files = []
	run_shell_parse_output "git diff --name-only #{merge.old_head}..#{merge.new_head}", repo do |pipe|
		while file = pipe.gets
			files << file.strip
		end
	end

	file_map = {}
	files.each do |file|
		run_shell_parse_output "git log --pretty=%h___%cD --abbrev-commit #{merge.old_head}..HEAD #{file}", repo do |pipe|
			hashes = []
			while hash = pipe.gets
				hashes << hash.strip
			end

			file_map[file] = hashes
			puts "File: #{file}, #{hashes.size}"
		end
	end

	return file_map
end

ActiveRecord::Base.establish_connection(
	:adapter => 'sqlite3',
	:database => 'visualMerge.db'		
)

action = ARGV[0]

case action
when 'init'
	run_shell 'mkdir .visualMerge', '.'
	
	run_shell "rm -f '.visualMerge/visualMerge.db'", GIT_REPO_HOME
	run_shell "rm -f '.git/hooks/post-merge'", GIT_REPO_HOME
	run_shell "rm -f '.git/hooks/common.rb'", GIT_REPO_HOME

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
	
when 'files'
	ensure_dir '.visualMerge' do
		puts git_changed_files GIT_REPO_HOME
	end
end
