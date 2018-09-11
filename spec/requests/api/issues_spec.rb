require 'rails_helper'
require 'helpers/api/issues_helper'
require 'helpers/api/api_helper'
require 'json'

describe Issue do
  let(:person) { create(:empty_person) }
  let(:admin_user) { create(:admin_user) }

  def assert_issue_integrity(seed_list = [])
    Issue.first.person.should == person
    seed_list.each do |seed_type|
      seed_type.constantize.count.should == 1
      seed_type.constantize.last.issue.should == Issue.first
      if !SELF_HARVESTABLE_SEEDS.include? seed_type
        seed_type.constantize.last.attachments.count.should == 1
      end
    end
  end

  def assert_replacement_issue_integrity(seed_list = [])
    Issue.count == 2
    seed_list.each do |seed_type|
      seed_type.constantize.count.should == 2
      seed_type.constantize.last.reload.issue.should == Issue.last
      seed_type.constantize.last.attachments.count.should == 1
    end
  end

  describe 'Creating a new user Issue' do
    it 'requires a valid api key' do
      forbidden_api_request(:post, "/issues",
        Api::IssuesHelper.issue_for(nil, person.id))
    end

    it 'responds with an Unprocessable Entity when body is empty' do
      api_request :post, "/issues", {}, 422
    end

    it 'creates a new issue, and adds observation' do
      reason = create(:human_world_check_reason)

      expect do
        api_create('/issues', Api::IssuesHelper.issue_for(nil, person.id))
      end.to change{ Issue.count }.by(1)

      issue_id = api_response.data.id

      assert_logging(Issue.last, :create_entity, 1)

      expect do
        api_create('/observations', {
          type: 'observations',
          attributes: {
            note: 'Observation Note',
            scope: 'admin',
          },
          relationships: {
            issue: {
              data: { type: 'issues', id: issue_id }
            },
            observation_reason: {
              data: { type: 'observation_reasons', id: reason.id }
            }
          }
        })
      end.to change{ Observation.count }.by(1)

      observation_id = api_response.data.id

      assert_logging(Observation.last, :create_entity, 1)

      api_get("/issues/#{issue_id}")

      assert_resource("issues", issue_id, api_response.data)
      r = api_response.data.relationships
      assert_resource("people", person.id, r.person.data)
      assert_resource("observations", observation_id, r.observations.data.first)
    end
  end

  describe "when changing state" do
    { complete: :draft,
      observe: :new,
      answer: :observed,
      dismiss: :new,
      reject: :new,
      approve: :new,
      abandon: :new
    }.each do |action, initial_state|
      it "It can #{action} issue" do
        issue = create(:basic_issue, state: initial_state, person: person)

        post "/api/issues/#{issue.id}/#{action}", 
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

        assert_response 200
      end

      it "It cannot #{action} approved issue" do
        issue = create(:basic_issue, state: :approved, person: person)

        post "/api/issues/#{issue.id}/#{action}", 
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
        assert_response 422
      end
    end
  end
end
