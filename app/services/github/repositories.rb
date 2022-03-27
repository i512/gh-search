module Github
  module Repositories
    DEFAULT_PAGE_SIZE = 5
    TooManyRequests = Class.new(StandardError)

    class << self
      def search(query:, page: nil, per_page: DEFAULT_PAGE_SIZE)
        results = Github.client.search_repos(query, page: page, per_page: per_page)

        repositories = results.items.map do |item|
          item_to_model(item)
        end

        [repositories, results.total_count]
      rescue Octokit::TooManyRequests => e
        raise TooManyRequests, e.message
      end

      private

      def item_to_model(item)
        GithubRepository.new(
          name: item.full_name,
          description: item.description,
          license: item.license&.name,

          html_url: item.html_url,
          clone_ssh_url: item.ssh_url,

          open_issues: item.open_issues,
          forks: item.forks,
          stars: item.stargazers_count,
        )
      end
    end
  end
end