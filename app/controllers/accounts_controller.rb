class AccountsController < ApplicationController
  
  include ZapUtil
  include DataSources

  before_filter :authenticate
  
  def index
    @client = MongoClient.new(MongoClient::DEFAULT_HOST, MongoClient::DEFAULT_PORT)
    @tenant_id = params[:tid]

    db = @client.db(@tenant_id)
    resultsets = []

    db.collection(ACCOUNT_DATASOURCE_NAME).find({}).each {|doc|
      resultsets << {
        "accountNumber" => doc["accountNumber"],
        "accountName" => doc["name"],
        "status" => doc["status"],
        "currency" => doc["currency"],
        "accountBalance" => doc["accountBalance"],
        "paymentType" => doc["defaultPaymentMethod"]["type"],
        "cmrr" => doc["cmrr"],
        "crmAccountID" => doc["crmAccountID"],
        "objID" => doc["_id"]}
    }
    @client.close

    @account_count = resultsets.size
    @account_table_head = "#{@account_count} Account Records Found"
    @json_response = {:response => resultsets}.to_json
  end

  def show
    @client = MongoClient.new(MongoClient::DEFAULT_HOST, MongoClient::DEFAULT_PORT)
    @tenant_id = params[:tid]
    obj_id = params[:id]
   
    # get to tenant's DB
    db = @client.db(@tenant_id)
    db.collection(ACCOUNT_DATASOURCE_NAME).find({:_id => BSON::ObjectId(obj_id)}).limit(1).each {|doc|
      # extract root object
      extract_datasource_root_object(doc, ACCOUNT_DATASOURCE_NAME)
      # extract other objects
      ACCOUNT_OBJECTS.each {|object_name|
        extract_datasource_object(doc, object_name)
      }
    }
    @client.close

    @account_table_head = "All Objects and Attributes Related To Account #{obj_id}"
    @json_response = {:response => {:account => @account, :billTo => @billTo,
      :soldTo => @soldTo, :defaultPaymentMethod => @defaultPaymentMethod, :parentAccount => @parentAccountt}}.to_json
    # puts @json_response.pretty_inspect
  end
end
