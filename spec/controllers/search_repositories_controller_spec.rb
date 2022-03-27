require_relative '../rails_helper'

RSpec.describe SearchRepositoriesController, type: :controller do
  describe "GET index" do
    let(:query) { 'query' }
    let(:per_page) { described_class::PER_PAGE_RESULTS }
    let(:repo_attrs) do
      {
        name: 'repo1',
        description: 'r1 description',
        license: 'license',

        html_url: 'html url',
        clone_ssh_url: 'ssh url',

        open_issues: 1,
        forks: 2,
        stars: 3,
      }
    end
    let(:repo1) { GithubRepository.new(repo_attrs) }
    let(:repo2) { GithubRepository.new(repo_attrs.merge(name: 'repo2')) }

    context 'no params' do
      it 'prepares an empty response' do
        get :index
        expect(assigns(:results)).to eq([])
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template('index')
      end
    end

    context 'with query param' do
      it 'requests repositories with service request' do
        expect(Github::Repositories).to receive(:search).with(
          query: query, per_page: per_page, page: 1,
        ).and_return([[], 0])

        get :index, params: { query: query }

        expect(assigns(:results)).to eq([])
        expect(assigns(:page)).to eq(1)
        expect(assigns(:pages)).to eq(0)
      end

      context 'with results' do
        it 'assigns results and page' do
          expect(Github::Repositories).to receive(:search).with(
            query: query, per_page: per_page, page: 1,
          ).and_return([[repo1, repo2], 2])

          get :index, params: { query: query }

          expect(assigns(:results)).to eq([repo1, repo2])
          expect(assigns(:page)).to eq(1)
          expect(assigns(:pages)).to eq(1)
        end

        context 'with results for multiple pages' do
          it 'sets pages parameter to the corrent number of pages' do
            expect(Github::Repositories).to receive(:search).with(
              query: query, per_page: per_page, page: 1,
            ).and_return([Array.new(5, repo1), 12])

            get :index, params: { query: query }

            expect(assigns(:pages)).to eq(3)
          end

          context 'with page param set' do
            it 'request correct page' do
              expect(Github::Repositories).to receive(:search).with(
                query: query, per_page: per_page, page: 2,
              ).and_return([Array.new(5, repo1), 12])

              get :index, params: { query: query, page: 2 }

              expect(assigns(:page)).to eq(2)
              expect(assigns(:pages)).to eq(3)
            end
          end
        end
      end
    end

    context 'when rate limited' do
      it 'renders rate limited page' do
        expect(Github::Repositories).to receive(:search).with(
          query: query, per_page: per_page, page: 1,
        ).and_raise(Github::Repositories::TooManyRequests.new('limit exceeded'))

        get :index, params: { query: query }

        assert_template :rate_limited
      end
    end
  end
end