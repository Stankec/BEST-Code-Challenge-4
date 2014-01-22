class CreateEdges < ActiveRecord::Migration
  def change
    create_table :edges do |t|
      t.belongs_to :nodeA, index: true
      t.belongs_to :nodeB, index: true
      t.float :relevanceFactor
      t.float :matrix00
      t.float :matrix01
      t.float :matrix10
      t.float :matrix11

      t.timestamps
    end
  end
end
