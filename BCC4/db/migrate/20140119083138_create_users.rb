class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :nameFirst
      t.string :nameLast
      t.string :nameNickname
      t.boolean :useNickname
      t.string :loginUsername
      t.string :password
      t.string :contactEmail

      t.timestamps
    end
  end
end
