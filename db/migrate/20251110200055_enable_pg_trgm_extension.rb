class EnablePgTrgmExtension < ActiveRecord::Migration[8.0]
  def change
    # Enable the pg_trgm extension for fuzzy text search
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')
  end
end
