require "consul/version"
require "consul/client"

module Consul
  def self.new(*args)
    Client.new(*args)
  end
end
