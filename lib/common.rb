
class Merge < ActiveRecord::Base
		
end

def read_HEAD(repo)
	sha = ""
	run_shell_parse_output 'git rev-parse --short HEAD', repo do |pipe|
		sha = pipe.gets
		sha.strip!
	end

	sha
end

def register_merge(repo)
	last_merge = Merge.last

	new_head = read_HEAD(repo)
	old_head = new_head
	old_head = last_merge.new_head if last_merge

	Merge.create :old_head => old_head,
		:new_head => new_head
end

def ensure_dir(path, &code)
	dir = Dir.pwd
	begin
		Dir.chdir path
		code.call
	ensure
		Dir.chdir dir
	end
end


def run_shell(cmd, path)
	ensure_dir(path) do
		puts "-> Changed wdir to #{Dir.pwd}"
		puts "-> Running command '#{cmd}'"

		system cmd	
	end

	if ($?.success?)
		puts "!> Process PID #{$?.pid} exited with status code #{$?.exitstatus}"		
		return true
	end	

	return false, $?.exitstatus
end

def run_shell_parse_output(cmd, path, &parser)
	ensure_dir(path) do
		puts "-> Changed wdir to #{Dir.pwd}"
		puts "-> Running command '#{cmd}'"

		pipe = IO.popen cmd	do | pp |
			
			parser.call(pp)		
		end
		
	end

	puts "!> Process PID #{$?.pid} exited with status code #{$?.exitstatus}" unless $?.success?
	return $?.success?, $?.exitstatus		
end