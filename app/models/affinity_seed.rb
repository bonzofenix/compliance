class AffinitySeed < ApplicationRecord
  include Garden::Seed
  include Garden::Kindify
  belongs_to :related_person, class_name: 'Person'
  #validates :kind, relationship_kind: true

  kind_mask_for :affinity_kind, "AffinityKind"
end
