require 'spec_helper'

  describe 'Deactivate user on failed charge' do
    let(:event_data) do
      {
  "id"=> "evt_103ZNI2nsCLSc89fDqgd1UBa",
  "created"=> 1393447488,
  "livemode"=> false,
  "type"=> "charge.failed",
  "data"=> {
    "object"=> {
      "id"=> "ch_103ZNI2nsCLSc89fPdgusviZ",
      "object"=> "charge",
      "created"=> 1393447488,
      "livemode"=> false,
      "paid"=> false,
      "amount"=> 999,
      "currency"=> "usd",
      "refunded"=> false,
      "card"=> {
        "id"=> "card_103ZNH2nsCLSc89fIdfr4VEt",
        "object"=> "card",
        "last4"=> "0341",
        "type"=> "Visa",
        "exp_month"=> 5,
        "exp_year"=> 2017,
        "fingerprint"=> "PbfuunF9jY6VJS45",
        "customer"=> "cus_3ZMeUdleXkekqe",
        "country"=> "US",
        "name"=> null,
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
      "captured"=> false,
      "refunds"=> [],
      "balance_transaction"=> nil,
      "failure_message"=> "Your card was declined.",
      "failure_code"=> "card_declined",
      "amount_refunded"=> 0,
      "customer"=> "cus_3ZMeUdleXkekqe",
      "invoice"=> nil,
      "description"=> "payment to fail",
      "dispute"=> nil,
      "metadata"=> {}
    }
  },
  "object"=> "event",
  "pending_webhooks"=> 1,
  "request"=> "iar_3ZNIC6MY5jVSuj"
}
    end

    it "deactivates a user with the web hook data from stripe for charge failed", :vcr do
    mark = Fabricate(:user, customer_token: "cus_3ZMeUdleXkekqe")
    post "/stripe_events", event_data
    expect(mark.reload).not_to be_active
  end
end
  end