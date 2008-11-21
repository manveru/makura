class UUIDCache
  attr_accessor :min, :max, :server

  def initialize(server, min = 500, max = 1500)
    @server, @min, @max = server, min, max
    @uuids = []
  end

  def next
    fetch if @uuids.size < min
    @uuids.shift
  end

  def fetch(count = 0)
    todo = max - @uuids.size
    count = [min, todo, max].sort[1]
    uuids = @server.post('/_uuids', :count => count)['uuids']
    @uuids.concat(uuids)
  end
end
