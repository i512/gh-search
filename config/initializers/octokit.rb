Octokit.configure do |c|
  token = ENV['GITHUB_ACCESS_TOKEN']
  if token
    c.access_token = token
  else
    Rails.logger.warn('GITHUB_ACCESS_TOKEN variable was not set. Client might be rate limited')
  end

  c.connection_options = {
    request: {
      open_timeout: 2,
      timeout: 5
    }
  }
end