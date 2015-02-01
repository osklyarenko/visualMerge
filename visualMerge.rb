#!/usr/bin/env ruby

require 'rubygems'
require 'active_record'
require 'json'
require 'time'
require 'active_support/all'

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

	def git_read_iso_time(line)
		DateTime.strptime(line, '%Y-%m-%d %H:%M:%S %z')
	end

	def git_oldest_hash_since(repo, since)
		hash = ''

		run_shell_parse_output "git log --pretty='%ci___%h'  --after '#{since}' | sort| head -n 1", repo do |pipe|
			line = pipe.gets

			_hash, _ = line.match(/^.*___(\w*)$/).captures
			hash = _hash.strip if _hash 
			# commit_time = DateTime.strptime line, '%Y-%m-%d %H:%M:%S %z'
		end

		hash
	end	

	def git_changed_files_in_hash_range(repo, old_hash, new_hash)
		files = []

		run_shell_parse_output "git diff --name-only #{old_hash}..#{new_hash}", repo do |pipe|
			while file = pipe.gets
				files << file.strip if file
			end
		end

		files
	end

	def git_build_file_map_in_hash_range(repo, changed_files, old_hash, new_hash)
		file_map = {}

		changed_files.each do |file|
			run_shell_parse_output "git log --pretty=%h___%ci --abbrev-commit #{old_hash}..#{new_hash} #{file}", repo do |pipe|
				hashes = []
				while hash = pipe.gets
					hash.strip!
					sha, time = hash.match(/^([a-z0-9]*)___(.+)$/).captures
					puts "time " + time
					hashes << { :hash => sha, :time =>  git_read_iso_time(time) }
				end

				file_map[file] = hashes
				puts "#{hashes.size}, #{file}"
			end
		end

		file_map		
	end

	def git_changed_files_since_yesterday(repo)
		hash = git_oldest_hash_since GIT_REPO_HOME, 1.day.ago.beginning_of_day

		changed_files = git_changed_files_in_hash_range GIT_REPO_HOME, "#{hash}~1", 'HEAD'

		file_map = git_build_file_map_in_hash_range GIT_REPO_HOME, changed_files, "#{hash}~1", 'HEAD'

		puts "In git_changed_files_since_yesterday"
		puts file_map
		file_map
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
				puts git_changed_files_since_yesterday '.'
			end
		when 'show'
			ensure_dir GIT_REPO_HOME do
				ActiveRecord::Base.establish_connection(
					:adapter => 'sqlite3',
					:database => '.visualMerge/visualMerge.db'		
				)
			
				files = git_changed_files_since_yesterday '.'

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

				documents
			end 
		end
	end
end

if ARGV
	APP = VisualMerge.new ARGV
	APP.perform_action
end





