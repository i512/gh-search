class GithubRepository < Dry::Struct
  attribute :name, Types::String
  attribute :description, Types::String.optional
  attribute :license, Types::String.optional

  attribute :html_url, Types::String
  attribute :clone_ssh_url, Types::String

  attribute :open_issues, Types::Integer
  attribute :forks, Types::Integer
  attribute :stars, Types::Integer
end