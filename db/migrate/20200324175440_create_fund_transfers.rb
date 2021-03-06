class CreateFundTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :fund_transfers do |t|
      t.references :source_person, foreign_key: {to_table: :people}, null: false
      t.references :target_person, foreign_key: {to_table: :people}, null: false
      t.decimal :amount,
                precision: 20,
                scale: 8,
                null: false
      t.datetime :transfer_date, null: false
      t.decimal :exchange_rate_adjusted_amount,
                precision: 20,
                scale: 8,
                null: false
      t.integer :currency_id, null: false
      t.string :external_id, null: false

      t.timestamps
    end
  end
end
