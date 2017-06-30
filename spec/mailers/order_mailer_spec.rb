require "rails_helper"

RSpec.describe OrderMailer, type: :mailer do

  describe 'assignee_email' do

    let(:order) { create(:order) }
    let(:order_with_digital_item) { create(:order_with_digital_item) }
    let(:user) { create(:user) }
    let(:mail) { OrderMailer.assignee_email(order, user, 'order/url').deliver_now }
    let(:mail_digital) { OrderMailer.assignee_email(order_with_digital_item, user, 'order/url').deliver_now }

    it 'sends an email' do
      expect { OrderMailer.assignee_email(order, user, 'order/url').deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
      expect(mail.bcc).to eq(ENV['order_notification_default_email'].split(',').map { |e| e.strip })
    end

    it 'adds cc to orders with digital items' do
      expect(mail_digital.cc).to eq(ENV['order_notification_digital_items_email'].split(',').map { |e| e.strip })
    end

  end

end
