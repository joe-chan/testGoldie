class TenantsController < ApplicationController

  before_filter :authenticate

  def index
    result_set_array = []

    @client = MongoClient.new(MongoClient::DEFAULT_HOST, MongoClient::DEFAULT_PORT)
    
    @client.database_names.each {|db_name|
      db = @client.db(db_name)
      collections = []

      collections = db.collection_names.reject {|name|
        name == 'tenant' || name == 'system.indexes'
      }

      db.collection('tenant').find.limit(1).each {|tenant|
        result_set_array << {:id => tenant['id'].to_i, :name => tenant['name'], :collections => collections}
      }
    }
    @client.close

    @tenant_count = result_set_array.size
    @tenant_collection_table_head = "#{@tenant_count} Tenants Found"
    @json_response = {:response => result_set_array}.to_json

  end
  
end
