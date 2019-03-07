# pull-requests
workflow "Pull Request" {
  on = "pull_request"
  resolves = ["Run Tests"]
}

action "Run Tests" {
  uses = "./.github/lua"
  args = "run-tests.sh"
}

# releases
workflow "Releases" {
  on = "release"
  resolves = ["Test"]
}

action "Test" {
  uses = "./.github/lua"
}

action "Release" {
  uses = "./.github/lua"
  needs = ["Test"]
}
