require 'rails_helper'

RSpec.describe PersonTagging, type: :model do
  let(:person) { create(:empty_person) }
  let(:tag) { create(:person_tag) }

  it 'validates non null fields' do
    invalid = PersonTagging.new
    expect(invalid).not_to be_valid
    expect(invalid.errors.keys).to match_array(%i[
      person tag ])
  end

  it 'is valid with a person, and tag' do
    expect(create(:full_person_tagging)).to be_valid
  end

  it 'is invalid tag type' do
    person_tag = build(:invalid_type_person_tagging)
    expect(person_tag).to_not be_valid
    expect(person_tag.errors.messages[:tag]).to include("can't be blank and must be person tag")
  end

  it 'validates that we cannot add the same tag twice' do
    expect do
      person.tags << tag
    end.to change{ person.tags.count }.by(1)

    expect(person).to be_valid

    expect {person.tags << tag }.to raise_error(ActiveRecord::RecordInvalid,
      "Validation failed: Tag can't contain duplicates in the same person")
  end

  it "does not allow using tags not managed by admin" do
    admin_user = AdminUser.current_admin_user = create(:admin_user)
    person = create(:empty_person)

    PersonTagging.create!(person: person, tag: create(:some_person_tag))
    create(:admin_tagging_to_apply_rules, admin_user: admin_user)

    invalid = PersonTagging.new(person: person, tag: create(:some_person_tag))
    expect(invalid).not_to be_valid
    expect(invalid.errors[:person]).to eq ['admin_cant_manage_tag']
  end
end
