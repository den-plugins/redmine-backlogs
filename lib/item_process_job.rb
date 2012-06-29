class ItemProcessJob < Struct.new(:params)
  def perform
    #Item.update(params)
  end
end
