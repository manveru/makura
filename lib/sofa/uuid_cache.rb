class UUIDCache
  attr_accessor :min, :max, :server, :pretty

  def initialize(server, min = 500, max = 1500, pretty = true)
    @server, @min, @max, @pretty = server, min, max, pretty
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
    uuids.map!{|u| pretty_from_md5(u) } if pretty
    @uuids.concat(uuids)
  end
end
