require 'rails_helper'

describe RiskScoreSeed do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed) {
    create(:risk_score_seed,
      issue: create(:basic_issue)
    )
  }

  it_behaves_like 'archived_seed', :full_risk_score

  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end

  it_behaves_like 'observable'

  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      issue = create(:basic_issue, person_id: person_id)
      create(:full_risk_score_seed, issue: issue)
    }

  it_behaves_like 'model_validations', described_class
end
