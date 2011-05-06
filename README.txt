Description
===========
This tool auto-detects the addition and removal of git release-candidate ("rc") or "hotfix" branches and adds or removes hudson projects ("jobs") accordingly.

It is meant for projects which use Vincent Driessen's git branching model or similar (see http://nvie.com/posts/a-successful-git-branching-model/ ).

For example, the following command:

    ./manage_dynamic_branches.rb world-domination git@github.com:drevil/secretplan.git

would first scan the "secretplan" git repo for branches prefixed rc- or hotfix- which were not already on your hudson server, and would add a corresponding hudson project ("job") for each. E.g. the branch rc-0.4 would have created for it the job "world-domination-rc-0.4".  We assume world-domination-develop job already exists (see elsewhere).
It will then delete any hudson jobs for that project name which do not have corresponding git branches.  So if it sees the hudson project world-domination-rc-0.3 but you've recently deleted the branch rc-0.3 from git, it will delete that branch (without any warning).

Usage:
======
It is envisaged the user will set up scheduling (ideally by hudson) so that the following command is run periodically, thus keeping hudson jobs in sync with git branches.

On the hudson server, run: 
    ./manage_dynamic_branches.rb job-base-name git-url

For hudson job addition to be successful, there must already exist a job for the "develop" branch of your project (so in the above example, a job called job-base-name-develop).  This job config will be cloned, only occurrences of the branch name "develop" will be subsitituted with origin/{branch_name}.

It is assumed that the local machine is the hudson server (http calls are made to localhost, and the local filesystem is inspected for the existence of jobs).

WARNING: command-line inputs are taken as given and used to formulate further commands, without screening.  Don't use untrusted sources for these inputs.

Scheduling - cron vs hudson:
============================
Though you could simply schedule it in cron, it is recommended the tool be scheduled as a hudson job itself, so that you get an alert from CI if this critical part fails.  Hudson also makes the logs more readily available, and allows more projects to be monitored.

Installation:
==============
 * make a backup of your hudson jobs!
 * download to your hudson server, e.g. 
 * * git@github.com:nbogie/hudson-dynamic-branch-manager.git /opt/hudson_branch_mgr/
 * optionally set up a scheduled hudson job, to keep your jobs in sync with your branches

Setting up a hudson job
=======================
 * Create a new free hudson job e.g. "BranchDiscovery", 
 * select no source control management
 * schedule it as frequent as you like
 * Add a build step "execute shell", having the following command:
 * * cd /opt/hudson_branch_mgr/ && ruby manage_dynamic_branches.rb your_project_name your_git_repo_url
 * repeat previous step for each project whose branches you want tracked

While you could set the project scm to be the github url for this tool, that is less safe.  Why trust that this tool's account will never be compromised?

TODO
====
 * Needs tightening up to ensure all failures are caught and an error code returned (especially in the git - grep pipeline).
 * Consider allowing a grace period so that projects for deleted branches are not immediately deleted (especially if they didn't pass in their last run).

Alternative approaches - discussion
===================================
Where callbacks are available from your SCM repo to signal, say, the creation and deletion of branches, they could be used to simplify some of the work here.  However, if the "branch-created" callback fails as we assume it sometimes will (e.g. due to a temporarily unavailable network), the SCM and CI will now be out of sync.  A callback on each commit could ensure the existence of the relevant branch, but the problem remains for branch deletion events, and anyway the per-commit event solution would threaten to bring a race condition to the CI project management when multiple commits come quickly on the same branch.  I prefer having the CI poll.

Credits
=======
Thanks to http://pachube.com/ for allowing me to open-source this.
