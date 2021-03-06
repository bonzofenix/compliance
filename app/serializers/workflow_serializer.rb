class WorkflowSerializer 
  include FastJsonapiCandy::Serializer
  set_type 'workflows'
 
  build_timestamps
  build_belongs_to :issue
  build_has_many :tasks

  attributes *%i(state scope workflow_type all_task_in_final_state? started?)
end