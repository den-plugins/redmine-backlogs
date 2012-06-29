class ItemProcessJob < Struct.new(:params)
  def perform
    item = Item.update(params)
  end
end
