This tool auto-detects addition/removal of git rc or hotfix branches and adds/removes hudson projects ("jobs") accordingly.

Though you could simply schedule it in cron, it is recommended the tool be scheduled as a hudson job itself, so that you get an alert from CI if this critical part fails.

This is meant for projects which use Vincent Driessen's git branching model or similar (see http://nvie.com/posts/a-successful-git-branching-model/ ).

This job should look for hotfixes and rcs that need to be tested by hudson, and add them as new jobs.
It should also remove rc and hotfix jobs from hudson which are no longer in git and which are older than say 2 mth.

When the script is called, any branches of the given project with one of the the following prefixes will be added: rc- hotfix- testme- when found in the given git repo, and any projects that look to have been made from similarly-prefixed but non-existent (presumed deleted) branches will be deleted.

Consider allowing a grace period so that projects for deleted branches are not immediately deleted (especially if they didn't pass in their last run).

WARNING: command-line inputs are taken as given and used to formulate further commands, without screening.  Don't use untrusted sources for these inputs.

Installation:
==============
 * make a backup of your hudson jobs!
 * install on your hudson server, e.g. in /opt/hudson_branch_mgr/
 * optionally set up a scheduled hudson job, to keep your jobs in sync with your branches

Setting up a hudson job
=======================
 * Create a new free hudson job e.g. "BranchDiscovery", 
 * select no source control management
 * schedule it as frequent as you like
 * Add a build step: execute shell: cd /opt/hudson_branch_mgr/ && ruby manage_dynamic_branches.rb myprojectname git@github.com:me/myprojectrepourl.git
 * repeat previous step for each project whose branches you want tracked

While you could set the project scm to be the github url for this tool, that is less safe.  Why trust that this tool's account will never be compromised?

