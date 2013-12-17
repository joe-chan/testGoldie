class TransactionsController < ApplicationController
  
  include ZapUtil
  include AggUtil
  include DataSources
  include LogProcessor
  
  before_filter :authenticate

  def index
    @client = MongoClient.new(MongoClient::DEFAULT_HOST, MongoClient::DEFAULT_PORT)
    @tenant_id = params[:tid]

    db = @client.db(@tenant_id)
    resultsets = []

    @collection = db.collection(TRANSACTION_DATASOURCE_NAME)
    @collection.find({}).each {|doc|
      resultsets << {"operation" => doc["operation"],
        "type" => doc["type"],
        "tenantId" => doc["tenantId"],
        "objID" => doc["_id"]}
    }
    @client.close

    @transaction_count = resultsets.size
    @transaction_table_head = "#{@transaction_count} Transaction Records Found"
    @json_response = {:response => resultsets}.to_json
  end

  def show
    @client = MongoClient.new(MongoClient::DEFAULT_HOST, MongoClient::DEFAULT_PORT)
    @tenant_id = params[:tid]
    obj_id = params[:id]
    real_object =""

    if params[:do]
      process_one_log(@client, @tenant_id, obj_id)
      flash[:notice] = "Transaction has successfully been applied."
      redirect_to :action => 'index', :tid => @tenant_id
      return
    end

    # get to tenant's DB
    db = @client.db(@tenant_id)
    db.collection(TRANSACTION_DATASOURCE_NAME).find({:_id => BSON::ObjectId(obj_id)}).limit(1).each {|doc|
      # extract root object
      # puts "* #{doc.pretty_inspect}"
      # puts "** #{doc["type"]}"
      # puts "*** #{doc["values"].pretty_inspect}"
      real_object = doc["type"]
      real_doc = doc["values"]

      case real_object
      when INVOICEITEM_DATASOURCE_NAME
        # extract other objects
        extract_datasource_root_object(real_doc, INVOICEITEM_DATASOURCE_NAME)
        # extract invoiceitem
        INVOICEITEM_OBJECTS.each {|object_name|
          extract_datasource_object(real_doc, object_name)
        }
      else
        # extract other objects ONLY
        extract_datasource_root_object(real_doc, ACCOUNT_DATASOURCE_NAME)
        ACCOUNT_OBJECTS.each {|object_name|
          extract_datasource_object(real_doc, object_name)
        }
      end
    }
    @client.close

    @transaction_table_head = "All Objects and Attributes Related To #{real_object} #{obj_id}"
    case real_object
    when INVOICEITEM_DATASOURCE_NAME
      @json_response = {:response => {:invoiceItem => @invoiceItem, :invoice => @invoice, :account => @account, :billTo => @billTo,
        :soldTo => @soldTo, :defaultPaymentMethod => @defaultPaymentMethod, :parentAccount => @parentAccount,
        :ratePlanCharge => @ratePlanCharge, :ratePlan => @ratePlan,
        :subscription => @subscription, :amendment => @amendment, :productRatePlanCharge => @productRatePlanCharge,
        :productRatePlan => @productRatePlan, :product => @product}}.to_json
      render "invoiceitems/show"
    else
      @json_response = {:response => {:account => @account, :billTo => @billTo,
        :soldTo => @soldTo, :defaultPaymentMethod => @defaultPaymentMethod, :parentAccount => @parentAccountt}}.to_json
      render "accounts/show"
    end
    # puts @json_response.pretty_inspect
  end

  def apply

  end

end
