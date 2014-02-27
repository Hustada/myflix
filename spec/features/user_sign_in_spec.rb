require 'spec_helper'

feature 'user signs in' do
  scenario 'with valid email and password' do
    mark = Fabricate(:user)
    sign_in(mark)
    page.should have_content mark.full_name  
  end


   scenario "with deactivated user" do
    mark = Fabricate(:user, active: false)
    sign_in(mark)
    expect(page).not_to have_content(mark.full_name)
    expect(page).to have_content("Your account has been suspended, please contact customer service.")
  end
end
