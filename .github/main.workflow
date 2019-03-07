# pull-requests
workflow "Pull Request" {
  on = "pull_request"
  resolves = ["Run Tests"]
}

action "Run Tests" {
  uses = "./.github/lua"
}

# releases
workflow "Releases" {
  on = "release"
  resolves = ["Test and Release"]
}

action "Test and Release" {
  uses = "./.github/lua"
}
