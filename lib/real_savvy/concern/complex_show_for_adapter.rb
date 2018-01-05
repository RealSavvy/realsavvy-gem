module RealSavvy::Concern::ComplexShowForAdapter
  def show(complex_id: nil, feed: nil, key: nil)
    feed, key = complex_id.split('~') if complex_id && feed.nil? && key.nil?
    get("./api/v3/#{path_prefix}/#{feed}/#{key}")
  end
end
