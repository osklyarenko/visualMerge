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