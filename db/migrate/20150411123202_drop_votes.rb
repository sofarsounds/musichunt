class DropVotes < ActiveRecord::Migration
  def up
    drop_table "votes"
  end

  def down
    create_table "votes", force: :cascade do |t|
    t.integer  "user_id",      null: false
    t.integer  "votable_id",   null: false
    t.string   "votable_type", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "votes", ["user_id", "votable_id", "votable_type"], name: "index_votes_on_user_id_and_votable_id_and_votable_type", unique: true, using: :btree
  end
end
