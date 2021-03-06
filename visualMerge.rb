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

	def git_print_iso_time(time)
		time.strftime '%Y-%m-%d %H:%M:%S %z'
	end

	def git_oldest_hash_since(repo, since)
		hash = ''

		run_shell_parse_output "git log --pretty='%ci___%H'  --after '#{since}' | tail -n 1", repo do |pipe|
			line = pipe.gets

			hash, _ = line.match(/^.*___(\w*)$/).captures if line
			hash = hash.strip if hash 
		end

		hash
	end

	def git_most_recent_hash(repo, hashes)
		sorted = git_sort_hashes_by_date repo, hashes

		sorted.last.first
	end

	def git_sort_hashes_by_date(repo, hashes)
		hash_to_date = hashes.inject({}) do |map, hash|
			iso_date = ''

			run_shell_parse_output "git show --pretty=%ci --quiet #{hash}", repo do |pipe|
				line = pipe.gets
				
				iso_date = line.strip
			end

			map[hash] = git_read_iso_time(iso_date)

			map
		end

		hash_to_date.sort_by {|left, right| right }
	end

	def git_show_parents(repo, hash)
		parents = []
		run_shell_parse_output "git log --pretty=%P -n 1 #{hash}", repo do |pipe|
			line = pipe.gets

			parents = line.split
		end

		parents
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
			run_shell_parse_output "git log --pretty=%H___%ci --abbrev-commit #{old_hash}..#{new_hash} #{file}", repo do |pipe|
				hashes = []
				while hash = pipe.gets
					hash.strip!
					sha, commit_time = hash.match(/^([a-z0-9]*)___(.+)$/).captures
					hashes << { :hash => sha, :time =>  commit_time }
				end

				file_map[file] = hashes
				puts "#{hashes.size}, #{file}"
			end
		end

		file_map		
	end

	def time_diff_in(from, to)
		# in hours
		from_hrs = from.to_i / 1.hour
		to_hrs = to.to_i / 1.hour
		
		diff_hrs = to_hrs - from_hrs

		# in days
		from_days = from.to_i / 1.day
		to_days = to.to_i / 1.day
		
		diff_days = to_days - from_days

		# in weeks
		from_wks = from.to_i / 1.week
		to_wks = to.to_i / 1.week

		diff_weeks = from_wks - to_wks

		return {
			:hours => diff_hrs.abs,
			:days => diff_days.abs,
			:weeks => diff_weeks.abs
		}
	end

	def git_files_changed_since(repo, since)		
		
		hash = git_oldest_hash_since GIT_REPO_HOME, since

		parents = git_show_parents GIT_REPO_HOME, hash
		most_recent = git_most_recent_hash GIT_REPO_HOME, parents
		
		changed_files = []
		changed_files = git_changed_files_in_hash_range GIT_REPO_HOME, "#{most_recent}", 'HEAD' unless hash == ''

		file_map = git_build_file_map_in_hash_range GIT_REPO_HOME, changed_files, "#{most_recent}", 'HEAD'
		

		time_diff = time_diff_in DateTime.now, since
		return {
			:since => git_print_iso_time(since),
			:to => git_print_iso_time(DateTime.now),
			
			:hours_range =>  time_diff[:hours],
			:days_range => time_diff[:days],
			:weeks_range => time_diff[:weeks],

			:file_map => file_map
		}
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
			run_shell_parse_output "git log --pretty=%H___%cD --abbrev-commit #{merge.old_head}..HEAD #{file}", repo do |pipe|
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

	def sort_documents(documents)

		documents.reject { |doc| doc[:articles].empty? }.sort do |left, right|

			l_article, r_article = [left, right].map do |document|				
				articles = document[:articles] 				

				articles.min_by { |article|	article[0] }
			end

			l_article[0] <=> r_article[0]			
		end
	end

	def longer_file_path(full_file_path, short_file_path)
		return full_file_path if full_file_path == short_file_path 

		max_iter_count = 0
		full_file_path.ascend {|_| max_iter_count = max_iter_count + 1 }


		current_file_path = full_file_path
		current_short_path = Pathname.new ''

		for i in 1..max_iter_count
			parent, current_basename = current_file_path.split
			current_short_path = current_basename + current_short_path

			current_file_path = parent
			break if current_short_path.to_s.size > short_file_path.to_s.size		
		end
		
		return current_short_path	
	end


	def unique_files(files)

		files_grouped_by_short_name = files.group_by { |file| Pathname.new(file).basename.to_s }
		
		full_name2short_name = {}
		unify_eventually(files_grouped_by_short_name).each_pair do |k, v|
			full_name2short_name[v[0]] = k
		end

		return full_name2short_name
	end

	def unify_eventually(files_grouped_by_short_name)
		uniques = files_grouped_by_short_name.select {|k, v| v.size == 1 }
		non_uniques = files_grouped_by_short_name.select {|k, v| v.size > 1 }

		return uniques if non_uniques.empty?

		non_uniques.each_pair do |short_file_name, files|

			files.each do |f|
				longer_path = longer_file_path Pathname.new(f), Pathname.new(short_file_name)

				uniques[longer_path.to_s] = [] unless uniques[longer_path.to_s]
				uniques[longer_path.to_s] << f
			end
		end

		return unify_eventually(uniques)
	end

	
	def api_files_changed_since(since)
		meta = git_files_changed_since '.', since

		file_map = meta[:file_map]
		hours_range = meta[:hours_range]
		
		to_date = git_read_iso_time meta[:to]
		since_date = git_read_iso_time meta[:since]

		documents = []

		min_change = 3
		max_change = 13
		
		unique_file_names_map = unique_files file_map.keys

		file_map.each_pair do |file_name, changes|

			articles = []			
			changes.each do |change|
				change_time = git_read_iso_time change[:time]						
				time_diff = time_diff_in change_time, to_date

				change_size = 0
				run_shell_parse_output "git diff --numstat #{change[:hash]}^1 #{file_name}", GIT_REPO_HOME do |pipe|
					line = pipe.gets

					insertions, deletions, _ = line.match(/\s*(\d+|\-)\s*(\d+|\-).*/).captures if line
					change_size = (insertions.to_i + deletions.to_i) unless insertions == '-' or deletions == '-'
				end

				article = [time_diff[:hours], change_size]
				articles << article

				if change_size < min_change
					min_change = change_size
				end

				if change_size > max_change
					max_change = change_size
				end
				
				min_change = change_size if change_size < min_change
				max_change = change_size if change_size > max_change
			end
			
			file_path = Pathname.new file_name
			
			document = {
				:articles => articles,
				:total => changes.size,
				:name => file_path.basename.to_s,
				:unique_name => unique_file_names_map[file_name],
				:full_name => file_name,
			}

			documents << document
			puts "#{changes.size}, #{file_name}"
		end

		meta[:min_change] = min_change
		meta[:max_change] = max_change

		return {
			:documents => sort_documents(documents),
			:meta => meta
		}	
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
				puts git_changed_files_since '.', 1.day.ago.beginning_of_day
			end
		when 'show'
			meta = git_changed_files_since '.', 1.day.ago.beginning_of_day

			prepare_changeset_document
		end
	end
end

if ARGV
	APP = VisualMerge.new ARGV
	APP.perform_action
end





