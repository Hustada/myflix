require 'spec_helper'

describe "create payment on successful charge" do
  let(:event_data) do
    
 {
  "id"=> "evt_103ZL02nsCLSc89fTNWpbKfu",
  "created"=> 1393438982,
  "livemode"=> false,
  "type"=> "charge.succeeded",
  "data"=> {
    "object"=> {
      "id"=> "ch_103ZL02nsCLSc89f6sY6RirL",
      "object"=> "charge",
      "created"=> 1393438982,
      "livemode"=> false,
      "paid"=> true,
      "amount"=> 999,
      "currency"=> "usd",
      "refunded"=> false,
      "card"=> {
        "id"=> "card_103ZL02nsCLSc89fgB1GDr6r",
        "object"=> "card",
        "last4"=> "4242",
        "type"=> "Visa",
        "exp_month"=> 2,
        "exp_year"=> 2018,
        "fingerprint"=> "9KIMAEh5RxdM8gLK",
        "customer"=> "cus_3ZL0RoGhHEnQ3R",
        "country"=> "US",
        "name"=> nil,
        "address_line1"=> nil,
        "address_line2"=> nil,
        "address_city"=> nil,
        "address_state"=> nil,
        "address_zip"=> nil,
        "address_country"=> nil,
        "cvc_check"=> "pass",
        "address_line1_check"=> nil,
        "address_zip_check"=> nil
      },
      "captured"=> true,
      "refunds"=> [],
      "balance_transaction"=> "txn_103ZL02nsCLSc89fDu146SOM",
      "failure_message"=> nil,
      "failure_code"=> nil,
      "amount_refunded"=> 0,
      "customer"=> "cus_3ZL0RoGhHEnQ3R",
      "invoice"=> "in_103ZL02nsCLSc89fUaWv7E31",
      "description"=> nil,
      "dispute"=> nil,
      "metadata"=> {}
    }
  },
  "object"=> "event",
  "pending_webhooks"=> 1,
  "request"=> "iar_3ZL0jOJTINjKTF"
}

end



 it "creates a payment with the webhook from stripe for charge succeeded", :vcr do
    post "/stripe_events", event_data
    expect(Payment.count).to eq(1)
  end

  it "creates the payment associated with user", :vcr do
    alice = Fabricate(:user, customer_token: "cus_3ZL0RoGhHEnQ3R")
    post "/stripe_events", event_data
    expect(Payment.first.user).to eq(alice)
  end

  it "creates the payment with the amount", :vcr do
    alice = Fabricate(:user, customer_token: "cus_3ZL0RoGhHEnQ3R")
    post "/stripe_events", event_data
    expect(Payment.first.amount).to eq(999)
  end

  it "creates the payment with reference id", :vcr do
    alice = Fabricate(:user, customer_token: "cus_3ZL0RoGhHEnQ3R")
    post "/stripe_events", event_data
    expect(Payment.first.reference_id).to eq("ch_103ZL02nsCLSc89f6sY6RirL")
  end
end