require_relative '../../rails_helper'

RSpec.describe Github::Repositories do
  describe '#search' do
    let(:query) { 'query' }
    let(:page) { 2 }
    let(:total_count) { 123 }
    let(:repository) do
      GithubRepository.new(
        name: 'repo1',
        description: 'r1 description',
        license: 'license',

        html_url: 'html url',
        clone_ssh_url: 'ssh url',

        open_issues: 1,
        forks: 2,
        stars: 3,
      )
    end

    let(:results) do
      double(
        total_count: total_count,
        items: [
          double(
            'repo',
            full_name: repository.name,
            description: repository.description,
            license: double(name: repository.license),
            html_url: repository.html_url,
            ssh_url: repository.clone_ssh_url,

            open_issues: repository.open_issues,
            forks: repository.forks,
            stargazers_count: repository.stars,
          )
        ]
      )
    end

    it 'uses github client to request repos and converts them into app models' do
      expect(Github.client).to receive(:search_repos).with(
        query, page: page, per_page: described_class::DEFAULT_PAGE_SIZE,
      ).and_return(results)

      items, count = described_class.search(query: query, page: page)
      expect(items).to eq([repository])
      expect(count).to equal(total_count)
    end

    context 'rate limit exceeded' do
      it 'raises TooManyRequests error' do
        expect(Github.client).to receive(:search_repos).with(
          query, page: page, per_page: described_class::DEFAULT_PAGE_SIZE,
        ).and_raise(Octokit::TooManyRequests.new)

        expect {
          described_class.search(query: query, page: page)
        }.to raise_error(described_class::TooManyRequests)
      end
    end
  end
end