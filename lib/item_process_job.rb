class ItemProcessJob < Struct.new(:params, :user)
  def perform
    item = Item.update(params, user)
  end
end
