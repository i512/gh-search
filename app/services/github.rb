module Github
  class << self
    def client
      @client ||= Octokit::Client.new
    end
  end
end