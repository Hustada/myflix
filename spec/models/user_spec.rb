  require 'spec_helper'

    describe  User do
      it { should validate_presence_of(:email) }
      it { should validate_presence_of(:password) }
      it { should validate_presence_of(:full_name) }
      it { should validate_uniqueness_of(:email) }
      it { should have_many(:queue_items).order(:position)}
      it { should have_many(:reviews).order("created_at DESC")}

      it "behaves like tokenable" do
        let(:object) { Fabricate(:user) }
      end
    

    describe "#queued_video?" do
      it "returns true when the user queued the video" do
        user = Fabricate(:user)
        video = Fabricate(:video)
        Fabricate(:queue_item, user: user, video: video)
        user.queued_video?(video).should be_true
      end
    


      it "it returns false when the user hasn't queue the video" do
        user = Fabricate(:user)
        video = Fabricate(:video)
        user.queued_video?(video).should be_false
      end
    end

    describe "#follows?" do
      it "returns true if the user has a following relationship with another user" do
        mark = Fabricate(:user)
        bill = Fabricate(:user)
        Fabricate(:relationship, follower: mark, leader: bill)
        expect(mark.follows?(bill)).to be_true
      end 

      it "returns false if the user does not have a following relationship with another user" do
        mark = Fabricate(:user)
        bill = Fabricate(:user)
        ted = Fabricate(:user)
        Fabricate(:relationship, follower: mark, leader: ted)
        expect(mark.follows?(bill)).to be_false
      end
    end

    describe "#follow" do
      it "follows another user" do
        mark = Fabricate(:user)
        bill = Fabricate(:user)
        mark.follow(bill)
        expect(mark.follows?(bill)).to be_true
      end


      it "does not follow oneself" do
        mark = Fabricate(:user)
        mark.follow(mark)
        expect(mark.follows?(mark)).to be_false
      end
    end


      describe "deactivate!" do
        it "deactivates a user" do
          mark = Fabricate(:user, active: true)
          mark.deactivate!
          expect(mark).not_to be_active
      end
    end
  end 





