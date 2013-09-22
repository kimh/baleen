class CreateArProfiles < ActiveRecord::Migration
  def change
    create_table :ar_profiles do |t|
      t.string :name_profile
      t.integer :number_profile
      t.date :date_profile

      t.timestamps
    end
  end
end
