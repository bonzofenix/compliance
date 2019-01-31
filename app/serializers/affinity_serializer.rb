class AffinitySerializer
  include FastJsonapiCandy::Fruit
  set_type 'affinities'
  attributes :affinity_kind_code
  build_timestamps
  belongs_to :related_person,
    record_type: :people,
    serializer: 'PersonSerializer'
  derive_seed_serializer!
  derive_public_seed_serializer!
end
