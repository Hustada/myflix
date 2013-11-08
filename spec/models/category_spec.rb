require 'spec_helper'

describe Category do
  it "saves itself" do
  category = Category.new(name:'Horror')
  category.save
  expect(Category.first).to eq(category)
  end

  it "has many videos" do
    comedies = Category.create(name:'comedies')
    south_park = Video.create(title:'South Park', description:'Funny', category: comedies)
    my_two_dads = Video.create(title:'My Two Dads', description:'Horrible', category: comedies)
    expect(comedies.videos).to include(south_park, my_two_dads)
  

  end
end