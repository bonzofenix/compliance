require 'rails_helper'

describe AffinitySeed do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed)   { 
    create(:affinity_seed, 
      related_person: create(:empty_person),
      affinity_kind: AffinityKind.find_by_code('spouse')
  )}

  it_behaves_like 'observable'

  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      issue = create(:basic_issue, person_id: person_id)
      create(:full_affinity_seed, issue: issue)
    }

  it_behaves_like 'archived_seed', :full_affinity

  it_behaves_like 'model_validations', described_class

  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end

  it 'validates that a fruit with same people and kind already exist' do
    issue = create(:basic_issue)
    person = issue.person
    create(:full_affinity, person: person)

    issue = create(:basic_issue, person: person)
    seed = described_class.new(
      issue: issue,
      related_person: person.reload.affinities.first.related_person,
      affinity_kind_code: :business_partner
    )

    expect(seed).to_not be_valid
    expect(seed.errors[:base]).to eq ['affinity_already_exists']
  end

  it 'allow a seed with same people and kind if archived fruit already exist' do
    related_person = create(:light_natural_person)
    seed = create(:full_affinity_archived_seed_with_issue, related_person: related_person)
    seed.issue.approve!

    issue = create(:basic_issue, person: seed.issue.person)
    seed2 = described_class.new(
      issue: issue,
      related_person: related_person,
      affinity_kind_code: :business_partner
    )

    expect(seed2).to be_valid
  end

  it 'validates that we cannot add two identical affinities in a same issue' do
    issue = create(:basic_issue)
    related_person = create(:empty_person)

    create(:affinity_seed, affinity_kind_code: :business_partner,
      issue: issue, related_person: related_person)

      repeated_one = build(:affinity_seed, affinity_kind_code: :business_partner,
      issue: issue, related_person: related_person)

    expect(repeated_one).to_not be_valid
    expect(repeated_one.errors[:base]).to eq ['affinity_already_defined']
  end

  it 'validates that affinity is not already defined in active issues' do
    issue = create(:basic_issue)
    person = issue.person
    issue_two = create(:basic_issue, person: person)
    related_person = create(:empty_person)

    create(:affinity_seed, affinity_kind_code: :business_partner,
      issue: issue, related_person: related_person)

    repeated_one = build(:affinity_seed, affinity_kind_code: :business_partner,
      issue: issue_two, related_person: related_person)

    expect(repeated_one).to_not be_valid
    expect(repeated_one.errors[:base]).to eq ['affinity_already_defined']

    %i(complete observe answer).each do |action|
      issue.send("#{action}!")
      expect(repeated_one.save).to be false
      expect(repeated_one.errors[:base]).to eq ['affinity_already_defined']
    end

    issue.dismiss!
    expect(repeated_one.save).to be true
  end

  it 'validate that cannot link to itself' do
    person = create(:empty_person)
    issue = create(:basic_issue, person: person)
    seed = described_class.new(
      issue: issue,
      related_person: person,
      affinity_kind_code: :business_partner
    )

    expect(seed.save).to be false
    expect(seed.errors[:base]).to eq ['cannot_link_to_itself']
  end
end
