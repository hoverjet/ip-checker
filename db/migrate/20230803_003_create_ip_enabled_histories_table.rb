Sequel.migration do
  change do
    create_table :ip_enabled_histories do
      primary_key :id
      foreign_key :ip_id, :ips, null: false, on_delete: :cascade
      boolean :enabled, null: false
      column :changed_at, :timestamptz, null: false
    end
  end
end