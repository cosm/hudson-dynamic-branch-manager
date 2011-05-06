#!/usr/bin/env ruby

def exec_or_fail(cmd)
	sout = `#{cmd}`
	rc = $?
	if rc != 0
		raise "non-zero rc (#{rc}) for command: #{cmd}.  Stdout: #{sout}"
	end
	sout
end

def ensure_hudson_user
	u = exec_or_fail("whoami").chomp
	abort "must be run as hudson, not #{u}" if u!="hudson"
end

def calc_missing_jobs(git_repo_url, project_name)
	#branches
	#find the list of branches we're interested in.
	#TODO: detect when the git command has problems.  checking rc of the pipeline won't work - grep may return non-zero.
	bs = `git ls-remote #{git_repo_url} | grep "refs/heads" | awk '{print $2}' | sed 's%refs/heads/%%' | grep "^rc-\\|^hotfix\\|^testme"`.split
	bs2 = bs.map{|b| b.sub("origin/",'')} #in shortest, comparable forms
	#dirs (existing jobs) #instead we could use the api: https://hudson.example.com/api/json, but we're on the box!
	ds = Dir.glob("/var/lib/hudson/jobs/#{project_name}_*/").map {|d| File.basename d }
	ds2 = ds.map{|d| d.sub(project_name + "_", '')}.select{ |x| x.start_with?("hotfix") || x.start_with?("rc") || x.start_with?("testme")} #shortest form
	to_rem = ds2 - bs2
	to_add = bs2 - ds2
	return to_add, to_rem
end
def create_hudson_job_from_branch(project_name, simple_branch)
	job_name = "#{project_name}_#{simple_branch}"
	puts "will create #{job_name} from #{project_name}_develop, using branch: #{simple_branch}"
	exec_or_fail "./add_hudson_job.sh #{project_name} #{simple_branch}"
end

def remove_hudson_job(project_name, simple_name)
	job_name = "#{project_name}_#{simple_name}"
	puts "will remove hudson job #{job_name} based on #{simple_name}"
	exec_or_fail "./remove_hudson_job.sh #{project_name} #{simple_name}"
end

def manage_dynamic_branches_for_project(project_name, git_repo_url)
  ensure_hudson_user
  to_add,to_rem=calc_missing_jobs(git_repo_url, project_name)
  puts "Branches to add: #{to_add}"
  puts "Branches to remove: #{to_rem}"
  results1 = to_add.map { |addme| create_hudson_job_from_branch(project_name, addme) }
  results2 = to_rem.map { |killme| remove_hudson_job(project_name, killme) }
  puts results1, results2
end

#As an alternative top-level method, you could put your project details 
#in the script here and invoke only once
def manage_all_projects
  projects= [ 
    ["pachweb", "git@github.com/foo/bar.git"],
    ["axino", "git@github.com/baz/qux.git"],
  ]
  projects.each do |project_name, git_repo|
    manage_dynamic_branches_for_project(project_name, git_repo)
  end
end

if __FILE__ == $0
  abort "usage: #{__FILE__} project_name git_repo_url" if ARGV.size != 2
  project_name, git_repo_url = ARGV[0], ARGV[1]
  puts git_repo_url
  manage_dynamic_branches_for_project(project_name, git_repo_url)
end
