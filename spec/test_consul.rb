require "docker"

if ENV.key?("DOCKER_HOST")
  Docker.url = ENV.fetch("DOCKER_HOST")
end

class TestConsul
  IMAGE = "consul:v0.6.4"

  class << self
    def start
      host = URI(Docker.url).host

      unless Docker::Image.exist?(IMAGE)
        Docker::Image.create("fromImage" => IMAGE)
      end

      @container = Docker::Container.create(
        "Name" => "consul",
        "Image" => IMAGE,
        "Cmd" => %W[
          agent -server -bind=#{host} -client=#{host} -bootstrap-expect=1
        ],
        "ExposedPorts" => {
          "8500/tcp" => {}
        },
      )

      @container.start(
        "PortBindings" => {
          "8500/tcp" => [{ "HostPort" => "8500" }]
        },
        "HostConfig" => {
          "NetworkMode" => "host",
        },
      )

      Thread.new do
        File.open("consul.log", "w") do |file|
          @container.attach do |stream, chunk|
            file.print chunk
          end
        end
      end

      loop do
        begin
          print "Waiting for #{host}:8500..."
          socket = TCPSocket.open(host, 8500)
          socket.close
          puts " OK"
          break
        rescue
          print "."
          sleep 0.1
        end
      end

      connection = Excon.new(ENV.fetch("CONSUL_URL", "http://localhost:8500"))

      print "Waiting for cluster to become healthy"

      loop do
        response = connection.get(
          path: "/v1/status/leader",
        )

        if response.body == '""'
          print "."
          sleep 0.1
        else
          puts " OK"
          break
        end
      end
    end

    def stop
      @container && @container.delete(force: true)
    end
  end
end
