#!/usr/bin/env ruby

require 'rubygems'
require 'active_record'
require 'json'
require 'time'

load 'lib/common.rb'
load 'config.rb'

class VisualMerge

	def initialize(args)
		@action = args[0]
	end

	def init_db(repo)
		
		ActiveRecord::Schema.define do
			create_table :merges, :force => true do |t|
				t.column :old_head, :string, :null => false
				t.column :new_head, :string, :null => false
				
				t.timestamps
			end
		end

		register_merge repo	
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
					hash.strip!
					sha, time = hash.match(/^([a-z0-9]*)___(.+)$/).captures
					hashes << { :hash => sha, :time =>  Date.rfc2822(time) }
				end

				file_map[file] = hashes
				puts "File: #{file}, #{hashes.size}"
			end
		end

		return file_map
	end

	def perform_action()
		case @action
		when 'init'
			run_shell 'mkdir .visualMerge', GIT_REPO_HOME

			run_shell "rm -f '.visualMerge/visualMerge.db'", GIT_REPO_HOME
			run_shell "rm -f '.git/hooks/post-merge'", GIT_REPO_HOME
			run_shell "rm -f '.git/hooks/common.rb'", GIT_REPO_HOME

			run_shell "ln -s '#{Dir.pwd}/git/post-merge' post-merge", "#{GIT_REPO_HOME}/.git/hooks"	
			run_shell "ln -s '#{Dir.pwd}/lib/common.rb' common.rb", "#{GIT_REPO_HOME}/.git/hooks"	


			ensure_dir GIT_REPO_HOME do
				ActiveRecord::Base.establish_connection(
					:adapter => 'sqlite3',
					:database => '.visualMerge/visualMerge.db'		
				)

				init_db '.'
			end
			
			config_script = <<-EOS
				#!/bin/bash
				echo "VISUAL_MERGE_HOME = '#{Dir.pwd}'" > .git/hooks/visual_merge_config.rb
			EOS
			run_shell config_script, GIT_REPO_HOME
				
		when 'files'
			ensure_dir GIT_REPO_HOME do
				ActiveRecord::Base.establish_connection(
					:adapter => 'sqlite3',
					:database => '.visualMerge/visualMerge.db'		
				)
				puts git_changed_files '.'
			end
		when 'show'
			ensure_dir GIT_REPO_HOME do
				ActiveRecord::Base.establish_connection(
					:adapter => 'sqlite3',
					:database => '.visualMerge/visualMerge.db'		
				)
			
				files = git_changed_files '.'

				documents = []
				files.each_pair do |file_name, changes|

					articles = []
					changes.each do |change|
						article = [change[:time], 1]

						articles << article
					end
					
					document = {
						:articles => articles,
						:total => changes.size,
						:name => file_name
					}

					documents << document
					puts "#{changes.size}, #{file_name}"
				end

				puts "Documents"
				puts documents
			end 
		end
	end
end

if ARGV
	APP = VisualMerge.new ARGV
	APP.perform_action
end





