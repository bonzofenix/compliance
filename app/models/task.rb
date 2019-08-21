class Task < ApplicationRecord
  include AASM
  include Loggable
  include Parametrizable

  before_validation -> { to_underscore('task_type') }, on: [:create, :update]

  belongs_to :workflow

  ransack_alias :state, :aasm_state

  aasm do 
    state :new, initial: true
    state :started
    state :performed
    state :retried
    state :failed

    event :start do
      transitions from: [:new, :started], to: :started, guard: :start_workflow!
    end

    event :finish do 
      transitions from: [:started, :retried, :performed], to: :performed, guard: :has_an_output?
    end

    event :fail do
      transitions from: [:started, :retried, :failed], to: :failed
    end

    event :retry do
      transitions from: [:failed, :retried], to: :retried do
        guard do
          can_retry? && aasm.from_state != :retried
        end
      end
      after do
        self.update!(current_retries: self.current_retries + 1) if can_retry?
      end
    end
  end

  def start_workflow!
    return true if workflow.state == "started"
    workflow.start!
  end

  def state
    aasm_state
  end

  def can_retry?
    current_retries < max_retries
  end

  def has_an_output?
    !output.blank?
  end
end