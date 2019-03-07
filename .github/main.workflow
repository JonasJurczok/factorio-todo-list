workflow "PR" {
  on = "push"
  resolves = ["is pull request?"]
}

action "is pull request?" {
  uses = "actions/bin/filter@d820d56839906464fb7a57d1b4e1741cf5183efa"
  args = "ref refs/pulls/*"
}

workflow "Build release" {
  on = "push"
  resolves = ["is master?"]
}

action "is tag?" {
  uses = "actions/bin/filter@d820d56839906464fb7a57d1b4e1741cf5183efa"
  args = "tag"
}

action "is master?" {
  uses = "actions/bin/filter@d820d56839906464fb7a57d1b4e1741cf5183efa"
  needs = ["is tag?"]
  args = "branch master"
}
