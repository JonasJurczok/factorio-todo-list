# pull-requests
workflow "Pull Request" {
  on = "pull_request"
  resolves = ["Run Tests"]
}

action "Run Tests" {
  uses = "./.github/lua"
  args = ".github/run-tests.sh"
}

# releases
workflow "Releases" {
  on = "release"
  resolves = ["Release"]
}

action "Test" {
  uses = "./.github/lua"
  args = ".github/run-tests.sh"
}

action "Release" {
  uses = "./.github/lua"
  args = ".github/release.sh"
  needs = ["Test"]
}
