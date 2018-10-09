class Invoice < ApplicationRecord
  belongs_to :order

  validates :order, presence: true

  before_save do
    if self.invoice_date && !self.invoice_id
      self.invoice_id = generate_invoice_id
    end
    if self.custom_to
      self.custom_to.strip!
    end
  end


  def self.find_or_create_for_order(order_id, atts={})
    invoice = find_by(order_id: order_id.to_i)
    if !invoice
      atts ||= {}
      atts[:order_id] = order_id
      invoice = create!(atts)
    end
    invoice
  end


  def set_date_and_id
    if !invoice_date || !invoice_id
      date = invoice_date || Date.today
      iid = invoice_id || generate_invoice_id(date)
      update_attributes(invoice_date: date, invoice_id: iid)
    end
  end


  # Load custom concern if present - methods in concern override those in model
  begin
    include InvoiceCustom
  rescue
  end


  private


  def generate_invoice_id(date=nil)
    date ||= invoice_date
    user = order.users.first
    if user && user.last_name
      prefix = user.last_name.byteslice(0,3).upcase
    else
      prefix = 'CIR'
    end
    suffix = date.strftime("%m%d%y")
    "#{prefix}-#{suffix}"
  end

end
