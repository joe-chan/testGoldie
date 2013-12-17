class DatasourcesController < ApplicationController

  before_filter :authenticate

  def index
    @client = MongoClient.new(MongoClient::DEFAULT_HOST, MongoClient::DEFAULT_PORT)
    @tenant_id = params[:tid]

    db = @client.db(@tenant_id)
    collections = datasources = []

    db.collection('tenant').find.limit(1).each {|tenant|
      if tenant['id'].to_i.to_s == @tenant_id
        collections = db.collection_names.reject {|name|
          name == 'tenant' || name == 'system.indexes'
        }
        collections.each {|collection|
          datasources << {:datasource => collection, :document_count => db.collection(collection).size}
        }
        if datasources.empty?
          flash[:error] = "No Datasources Found for Tenant #{@tenant_id}"
          redirect_to :controller => 'tenants'
        end
      else
        flash[:error] = "Mismatched database name and Tenant ID  #{@tenant_id}"
        redirect_to :controller => 'tenant'
      end
    }
    @client.close
    
    @datasource_count = collections.size
    @datasource_table_head = "#{@datasource_count} Datasources Found"
    @json_response = {:response => datasources}.to_json
  end
end
