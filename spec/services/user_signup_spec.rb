require 'spec_helper'

  describe UserSignup do
    describe "#sign_up" do
      context "valid personal info and valid card" do
        let(:customer) { double(:customer, successful?: true) }

        before do
          StripeWrapper::Customer.should_receive(:create).and_return(customer)
        end

        after do
          ActionMailer::Base.deliveries.clear
        end


        it "creates a user" do
          UserSignup.new(Fabricate.build(:user)).sign_up("some_stripe_token", nil)
          expect(User.count).to eq(1)
        end

        it "makes the user follow the inviter" do
          mark = Fabricate(:user)
          invitation = Fabricate(:invitation, inviter: mark, recipient_email: 'joe@example.com')
          UserSignup.new(Fabricate.build(:user, email: "joe@example.com", password: "password", full_name: "Joe Doe")).sign_up("some_stripe_token", invitation_token)
          joe = User.where(email: 'joe@example.com').first
          expect(joe.follows?(mark)).to be_true
        end

          it "makes the inviter follow the user" do
          mark = Fabricate(:user)
          invitation = Fabricate(:invitation, inviter: mark, recipient_email: 'joe@example.com')
          UserSignup.new(Fabricate.build(:user, email: "joe@example.com", password: "password", full_name: "Joe Doe")).sign_up("some_stripe_token", invitation_token)
          joe = User.where(email: 'joe@example.com').first
          expect(mark.follows?(joe)).to be_true
        end

        it "expires the invitation upon acceptance" do
          mark = Fabricate(:user)
          invitation = Fabricate(:invitation, inviter: mark, recipient_email: 'joe@example.com')
          UserSignup.new(Fabricate.build(:user, email: "joe@example.com", password: "password", full_name: "Joe Doe")).sign_up("some_stripe_token", invitation_token)
          expect(Invitation.first.token).to be_nil
        end



      it "sends out email to the user with valid inputs" do
        UserSignup.new(Fabricate.build(:user, email: 'joe@example.com')).sign_up("some_stripe_token", nil)
        expect(ActionMailer::Base.deliveries.last.to).to eq(['joe@example.com'])
      end

      it "sends out email containing the user's name with valid inputs" do
        UserSignup.new(Fabricate.build(:user, full_name: "Joe Smith", email: 'joe@example.com')).sign_up("some_stripe_token", nil)
        expect(ActionMailer::Base.deliveries.last.body).to include("Joe Smith")
      end
    end

        context "valid personal info and declined card" do
        it "does not create a new user record" do
        customer = double(:customer, successful?: false, error_message: "Your card was declined.")
        StripeWrapper::Customer.should_receive(:create).and_return(customer)
        UserSignup.new(Fabricate.build(:user)).sign_up('1231241', nil)
        expect(User.count).to eq(0)
    end
  end

        context "invalid personal info" do
          it "does not create a user" do
          UserSignup.new(User.new(email: "mark@example.com")).sign_up('1231241', nil)  
          expect(User.count).to eq(0)
        end

    
          it "does not charge the card" do
            StripeWrapper::Customer.should_not_receive(:create)
            UserSignup.new(User.new(email: "mark@example.com")).sign_up('1231241', nil)
          end

          it "does not send out email with invalid inputs" do
            UserSignup.new(User.new(email: "mark@example.com")).sign_up('1231241', nil)
            expect(ActionMailer::Base.deliveries).to be_empty
          end
      end
    end
  end