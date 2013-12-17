class InvoiceitemsController < ApplicationController
  
  include ZapUtil
  include AggUtil
  include DataSources
  
  before_filter :authenticate

  def index
    @client = MongoClient.new(MongoClient::DEFAULT_HOST, MongoClient::DEFAULT_PORT)
    @tenant_id = params[:tid]

    db = @client.db(@tenant_id)
    resultsets = []

    @collection = db.collection(INVOICEITEM_DATASOURCE_NAME)
    @collection.find({}).each {|doc|
        resultsets << {"chargeAmount" => doc["chargeAmount"],
          "chargeDate" => doc["chargeDate"],
          "invoiceNumber" => doc["invoice"]["invoiceNumber"],
          "invoiceAmount" => doc["invoice"]["amount"],
          "invoiceStatus" => doc["invoice"]["status"],
          "subscriptionName" => doc["subscription"]["name"],
          "invoicePaymentAmount" => doc["invoice"]["paymentAmount"],
          "accountNumber" => doc["account"]["accountNumber"],
          "currency" => doc["account"]["currency"],
          "objID" => doc["_id"]}
    }
    @json_response_2 = {:response => total_invoice_amount}.to_json
    @json_response_3 = {:response => average_invoice_amount}.to_json
    @client.close

    @invoiceitem_count = resultsets.size
    @invoiceitem_table_head = "#{@invoiceitem_count} Invoiceitem Records Found"
    @json_response = {:response => resultsets}.to_json
  end

  def show
    @client = MongoClient.new(MongoClient::DEFAULT_HOST, MongoClient::DEFAULT_PORT)
    @tenant_id = params[:tid]
    obj_id = params[:id]
   
    # get to tenant's DB
    db = @client.db(@tenant_id)
    db.collection(INVOICEITEM_DATASOURCE_NAME).find({:_id => BSON::ObjectId(obj_id)}).limit(1).each {|doc|     
      # extract root object
      extract_datasource_root_object(doc, INVOICEITEM_DATASOURCE_NAME)
      # extract other objects
      INVOICEITEM_OBJECTS.each {|object_name|
        extract_datasource_object(doc, object_name)
      }
    }
    @client.close

    @invoiceitem_table_head = "All Objects and Attributes Related To InvoiceItem #{obj_id}"
    @json_response = {:response => {:invoiceItem => @invoiceItem, :invoice => @invoice, :account => @account, :billTo => @billTo,
      :soldTo => @soldTo, :defaultPaymentMethod => @defaultPaymentMethod, :parentAccount => @parentAccount,
      :ratePlanCharge => @ratePlanCharge, :ratePlan => @ratePlan,
      :subscription => @subscription, :amendment => @amendment, :productRatePlanCharge => @productRatePlanCharge,
      :productRatePlan => @productRatePlan, :product => @product}}.to_json
    # puts @json_response.pretty_inspect
  end
end
