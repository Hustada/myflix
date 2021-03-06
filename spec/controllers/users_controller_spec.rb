  require 'spec_helper'


  describe UsersController do
    describe 'GET new' do
      it "sets @user" do
        get :new
        expect(assigns(:user)).to be_instance_of(User)
      end
  end

  describe "POST create" do

    context "successful user sign up" do
      

    context "valid personal info and valid card" do
        let(:charge) { double(:charge, successful?: true) }

      before do
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
      end


      
      it "creates the user" do
        post :create, user: Fabricate.attributes_for(:user)
        expect(User.count).to eq(1)
      end



      it "redirects to the sign in page" do

        result = double(:sign_up_result, successful?: true)
        UserSignup.any_instance.should_receive(:sign_up).and_return(result)
        post :create, user: Fabricate.attributes_for(:user)
        expect(response).to redirect_to sign_in_path
      end
    end


    context "failed user sign_up" do
      it "render the :new template" do
        result = double(:sign_up_result, successful?: false, error_message: "This is an error message")
        UserSignup.any_instance.should_receive(:sign_up).and_return(result)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '1231241'
        expect(response).to render_template :new
      end

      it "sets the flash error message" do
        result = double(:sign_up_result, successful?: false, error_message: "This is an error message")
        UserSignup.any_instance.should_receive(:sign_up).and_return(result)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '1231241'
        expect(flash[:error]).to eq("This is an error message")
      end
    end

      

    context "valid personal info and declined card" do
      it "does not create a new user record" do
        charge = double(:charge, successful?: false, error_message: "Your card was declined")
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '1231241'
        expect(User.count).to eq(0)
      end


      it "renders the new template" do
        charge = double(:charge, successful?: false, error_message: "Your card was declined")
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '1231241'
        expect(response).to render_template :new
      end



      it "sets the flash error message" do
      charge = double(:charge, successful?: false, error_message: "Your card was declined")
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '1231241'
        expect(flash[:error]).to be_present
      end
    end


    context "with invalid personal info" do



      it "does not create the user" do
        expect(User.count).to eq(0)
      end

      it "render the :new template" do
        get :new
        expect(response).to render_template :new
      end

      it "does not charge the card" do
        StripeWrapper::Charge.should_not_receive(:create)
        post :create, user: { email: "mark@example.com" }
      end

      it "does not send out email with invalid inputs" do
        post :create, user: { email: "mark@example.com" }
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context "sending emails" do
      let(:charge) { double(:charge, successful?: true) }

     
      before do
        StripeWrapper::Charge.should_receive(:create).and_return(charge)

      end 

      after { ActionMailer::Base.deliveries.clear }

      
      it "sends out email to the user with valid inputs" do
        post :create, user: { email: "mark@example.com", password: "password", full_name: "Mark Hustad" }
        expect(ActionMailer::Base.deliveries.last.to).to eq(['mark@example.com'])
      end
     
      it "sends out email containing the users name with valid inputs" do
        post :create, user: { email: "mark@example.com", password: "password", full_name: "Mark Hustad" }
        expect(ActionMailer::Base.deliveries.last.body).to include('Mark Hustad')
      end
     

    end
    

    describe "GET show" do
      it_behaves_like "requires sign in" do
        let(:action) { get :show, id: 3 }
      end

      it "sets @user" do
        set_current_user
        mark = Fabricate(:user)
        get :show, id: mark.id
        expect(assigns(:user)).to eq(mark)
    end
  end


    describe "GET new_with_invitation_token" do
      it "renders the :new view template" do
        invitation = Fabricate(:invitation)
        get :new_with_invitation_token, token: invitation.token
        expect(response).to render_template :new  
      end

      it "sets @user with recipient's email" do
        invitation = Fabricate(:invitation)
        get :new_with_invitation_token, token: invitation.token
        expect(assigns(:user).email).to eq(invitation.recipient_email)
      end

      it "sets @invitation_token" do
        invitation = Fabricate(:invitation)
        get :new_with_invitation_token, token: invitation.token
        expect(assigns(:invitation_token)).to eq(invitation.token)
      end


      it "redirects to expired token page for invalid tokens" do
        get :new_with_invitation_token, token: 'asdfjlkd'
        expect(response).to expired_token_path
      end
    end
  end

