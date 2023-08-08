Sequel.migration do
  change do
    create_table(:ips) do
      primary_key :id
      inet :ip_address, null: false, unique: true
      boolean :enabled, null: false, default: true
    end
  end
end
