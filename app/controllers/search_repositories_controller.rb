class SearchRepositoriesController < ApplicationController
  PER_PAGE_RESULTS = 5
  INVALID_QUERY_CHARS = /[^\w-]/
  before_action :query, :page

  def index
    @results = []
    if query
      @results, total_items = Github::Repositories.search(
        query: query, page: page, per_page: PER_PAGE_RESULTS,
      )

      @pages = (total_items / PER_PAGE_RESULTS.to_f).ceil
    end

    @full_page = @results.size == PER_PAGE_RESULTS
  rescue Github::Repositories::TooManyRequests
    render :rate_limited
  end

  private

  def query
    @query = params[:query].presence&.gsub(INVALID_QUERY_CHARS, '')
  end

  def page
    @page = [params[:page].to_i, 1].max
  end
end
