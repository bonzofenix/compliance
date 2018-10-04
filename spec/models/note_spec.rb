require 'rails_helper'

RSpec.describe Note, type: :model do
  let(:person) { create(:empty_person) }

  it 'is not valid without body' do
    expect(described_class.new(person: person, body: nil))
      .to_not be_valid
  end
end
