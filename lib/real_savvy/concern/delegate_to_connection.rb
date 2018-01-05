module RealSavvy::Concern::DelegateToConnection
  def connection
    @connection
  end

  def get(*args)
    connection.get(*args)
  end

  def post(*args)
    connection.post(*args)
  end

  def put(*args)
    connection.put(*args)
  end

  def delete(*args)
    connection.delete(*args)
  end
end
