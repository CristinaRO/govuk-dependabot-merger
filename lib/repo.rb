require_relative "./github_client"
require_relative "./pull_request"

class Repo
  def initialize(repo_name)
    @repo_name = repo_name
  end

  def dependabot_pull_requests
    GitHubClient
      .instance
      .pull_requests("alphagov/#{@repo_name}", state: :open, sort: :created)
      .map { |api_response| PullRequest.new(api_response) }
  end
end
