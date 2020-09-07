require 'rails_helper'

describe 'Dashboard', js: true do
  it 'differenciates rows with priority bigger than zero' do
    login_as create(:admin_user)

    5.times do |n|
      create(:basic_issue, priority: n + 1)
    end

    6.times do
      create(:basic_issue)
    end

    visit '/'
    click_link 'All'
    expect(page).to have_selector(:css, '.top-priority', count: 5)
    expect(page).to have_selector(:css, '.zero-priority', count: 6)
  end
end
