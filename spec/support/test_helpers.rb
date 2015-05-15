require 'percy'

module TestHelpers
  def build_url(path)
    "#{Percy.client.base_url}#{path}"
  end
end
