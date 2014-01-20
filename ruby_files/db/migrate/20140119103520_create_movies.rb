class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string  :title
      t.integer :year
      t.date    :released
      t.integer :runtime
      t.text    :plot
      t.text    :awards
      t.string  :poster
      t.string  :imdbID
      t.boolean :isHidden
      t.boolean :isDummy

      t.timestamps
    end
  end
end
