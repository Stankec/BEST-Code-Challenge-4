class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :nameFirst
      t.string :nameLast
      t.string :nameNickname
      t.string :loginUsername
      t.string :loginPasswordSalt
      t.string :loginPasswordHash
      t.string :loginAuthToken
      t.string :contactEmail
      t.boolean :useNickname
      t.boolean :isAdmin

      t.timestamps
    end
  end
end
