    class UsersController < ApplicationController
      before_action :require_user, only: [:show]


      def new
        @user = User.new
      end

      def create
        @user = User.new(users_params)

        result = UserSignup.new(@user).sign_up(params[:stripeToken], params[:invitation_token])
      
      if result.successful?    
          flash[:success] = "Thanks for registering with Myflix. Please sign in now."
          redirect_to sign_in_path
        else
          flash[:error] = result.error_message

        if @user.valid?
          charge = StripeWrapper::Charge.create(
            :amount => 999,
            :card => params[:stripeToken],
            :description => "Sign up charge for #{@user.email}"
          )
          if charge.successful?
            @user.save
            handle_invitation
            AppMailer.delay.send_welcome_email(@user)
            flash[:success] = "Thanks for signing up for my shitty app. The videos are actually just PICTURES LOL. Thanks for the money!"
            redirect_to sign_in_path
        else
          flash[:error] = charge.error_message
          render :new
        end
      else
          flash[:error] = "Invalid user information. Please do it right this time."
          render :new
        end
      end
    

      def show
        @user = User.find(params[:id])
      end

      def new_with_invitation_token
        invitation = Invitation.where(token: params[:token]).first
        if invitation
        @user = User.new(email: invitation.recipient_email)
        @invitation_token = invitation.token
        render :new
      else
        redirect_to expired_token_path
      end
    end


    

 

    def users_params
      params.require(:user).permit(:email, :password, :full_name)
    end

    
    end

