module Metas
  EXTMETA="*.json"
  TARGET ="target"
  FIELDS = "fields"

  TID="tenantId"
  TYPE="type"
  OP = "operation"
  VALUE="values"
  class Metas
    def initialize(metas={})
      @metaStore = {}
      @userDefinedTypes=allUserDefinedDocs(metas)
      metas.each do |key,value|
        item = MetaItem.new(key,value,@userDefinedTypes)
        @metaStore[item.name] = item
      end

      @userDefinedTypes.each do |type|
        @metaStore.values.each do |item|
          if item.refs.include?(type) then
            refItems = item.refs[type] # an array, and each item {:path=>"",:belongTo:""}

            #TODO
            metaItem = @metaStore[type]
            for ri in refItems
              metaItem.appendRefs(ri)
            end

          end
        end
      end

    end

    def item(name)
      return @metaStore[name]
    end

    def isZObj?(type)
      return @userDefinedTypes.include?(type)
    end

    private
    def allUserDefinedDocs(metas)
      return metas.keys
    end

  end

  class MetaItem
    attr_reader :name, :refs, :inRefs, :isRoot, :linksInChild
    def initialize(name,json,userDefinedTypes)
      @name=name
      @obj = json
      @refs = {} # {"account":['invoiceItem.account','invoiceItem.parentAccount']}
      @defByMap={}
      @obj['fields'].each do |key,value|
        type= value['type']
        map_name=value['map_name']
        map_name=key if not map_name

        if userDefinedTypes.include?(type) then
          b_to=value['belong_to']
          b_spread=value['spread']
          b_spread= true if b_spread.class == NilClass
          if not @refs.has_key?(type) then # first time
            @refs[type] = []
          end
#          puts "name:#{@name},key:#{key},belongTo:#{b_to},spread:#{b_spread}"
          refItem={:path=>""<<@name<<"."<<key,:belongTo => b_to,:spread=>b_spread}
          @refs[type].push(refItem)
        end

        value['field_name']=key
        @defByMap[map_name] = value
      end
      @isRoot = @obj['isRoot']
      @inRefs=[]
      @linksInChild=[]
    end

    def isRoot?()
      return @isRoot
    end

    def appendRefs(inRefs)
      ri_path = inRefs[:path]
      ri_b_to = inRefs[:belongTo]

      if ri_b_to then
        # add to the list of child which is root
        self.appendLinkInChild(ri_path)
      end

      @inRefs << inRefs if inRefs
    end

    def appendLinkInChild(fieldPath)
      @linksInChild << fieldPath if fieldPath
    end

    def [](fieldKey)
      return @obj['fields'][fieldKey]
    end

    def field_def_by_map_field(mapName)
      return @defByMap[mapName]
    end

  end
  META_DEFS={
    "account" => {
      "isRoot" => true,
      "fields" => {
        "accountBalance" => {"type" => "BigDecimal"},
        "accountNumber" => {"type" => "String"},
        "additionalEmailAddresses" => {"type" => "String"},
        "allowInvoiceEditing" => {"type" => "Boolean"},
        "autoPay" => {"type" => "Boolean"},
        "billCycleDay" => {"type" => "Integer"},
        "billCycleDaySettingOption" => {"type" => "String"},
        "billTo" => {"type"=>"contact"},
        "billingBatch" => {"type" => "String"},
        "bulkUploadPartnerName" => {"type" => "String"},
        "businessUnit" => {"type" => "String"},
        "cmrr" => {"type" => "BigDecimal"},
        "communicationprofileID" => {"type" => "String"},
        "corporateBillingAddress" => {"type" => "String"},
        "createdByID" => {"type" => "String"},
        "createdDate" => {"type" => "Date"},
        "creditBalance" => {"type" => "BigDecimal"},
        "creditCardType" => {"type" => "String"},
        "crmAccountID" => {"type" => "String"},
        "csr" => {"type" => "String"},
        "currency" => {"type" => "String"},
        "defaultPaymentMethod" => {"type"=>"paymentMethod"},
        "id" => {"type" => "String"},
        "invoiceDeliveryPreferencesEmail" => {"type" => "Boolean"},
        "invoiceDeliveryPreferencesPrint" => {"type" => "Boolean"},
        "invoiceTemplateID" => {"type" => "String"},
        "lastInvoiceDate" => {"type" => "Date"},
        "memberID" => {"type" => "String"},
        "name" => {"type" => "String"},
        "notes" => {"type" => "String"},
        "parentAccount" => {"type"=>"account","spread"=>false},
        "parentID" => {"type" => "String"},
        "payByCCInProgress" => {"type" => "String"},
        "paymentGatewayName" => {"type" => "String"},
        "paymentTerm" => {"type" => "String"},
        "poNumber" => {"type" => "String"},
        "salesRep" => {"type" => "String"},
        "soldTo" => {"type"=>"contact"},
        "status" => {"type" => "String"},
        "taxExemptCertificateID" => {"type" => "String"},
        "taxExemptCertificateType" => {"type" => "String"},
        "taxExemptDescription" => {"type" => "String"},
        "taxExemptEffectiveDate" => {"type" => "String"},
        "taxExemptExpirationDate" => {"type" => "String"},
        "taxExemptIssuingJurisdiction" => {"type" => "String"},
        "taxExemptStatus" => {"type" => "String"},
        "totalInvoiceBalance" => {"type" => "BigDecimal"},
        "updatedByID" => {"type" => "String"},
        "updatedDate" => {"type" => "Date"},
        "vatNumber" => {"type" => "String"}
      }
    },
    "amendment" =>{
      "isRoot" => false,
      "fields" => {
        "autoRenew" => {"type"=>"Boolean"},
        "code" => {"type"=>"String"},
        "contractEffectiveDate" => {"type"=>"Date"},
        "createdByID" => {"type"=>"String"},
        "createdDate" => {"type"=>"Date"},
        "customerAcceptanceDate" => {"type"=>"Date"},
        "description" => {"type"=>"String"},
        "effectiveDate" => {"type"=>"Date"},
        "id" => {"type"=>"String"},
        "initialTerm" => {"type"=>"Integer"},
        "name" => {"type"=>"String"},
        "renewalTerm" => {"type"=>"Integer"},
        "serviceActivationDate" => {"type"=>"Date"},
        "status" => {"type"=>"String"},
        "subscriptionID" => {"type"=>"String"},
        "termStartDate" => {"type"=>"Date"},
        "termType" => {"type"=>"String"},
        "type" => {"type"=>"String"},
        "updatedByID" => {"type"=>"String"},
        "updatedDate" => {"type"=>"Date"}
      }
    },
    "contact" => {
      "isRoot" => false,
      "fields" => {
        "accountID" => {"type"=>"String"},
        "address1" => {"type"=>"String"},
        "address2" => {"type"=>"String"},
        "city" => {"type"=>"String"},
        "country" => {"type"=>"String"},
        "county" => {"type"=>"String"},
        "createdByID" => {"type"=>"String"},
        "createdDate" => {"type"=>"Date"},
        "description" => {"type"=>"String"},
        "fax" => {"type"=>"String"},
        "firstName" => {"type"=>"String"},
        "homePhone" => {"type"=>"String"},
        "id" => {"type"=>"String"},
        "lastName" => {"type"=>"String"},
        "mobilePhone" => {"type"=>"String"},
        "nickName" => {"type"=>"String"},
        "otherPhone" => {"type"=>"String"},
        "otherPhoneType" => {"type"=>"String"},
        "personalEmail" => {"type"=>"String"},
        "postalCode" => {"type"=>"String"},
        "stateprovince" => {"type"=>"String"},
        "taxRegion" => {"type"=>"String"},
        "updatedByID" => {"type"=>"String"},
        "updatedDate" => {"type"=>"Date"},
        "workEmail" => {"type"=>"String"},
        "workPhone" => {"type"=>"String"}
      }
    },
    "invoice" => {
      "isRoot" => false,
      "fields" =>{
        "adjustmentAmount" => {"type"=>"BigDecimal"},
        "amount" => {"type"=>"BigDecimal"},
        "amountWithoutTax" => {"type"=>"BigDecimal"},
        "balance" => {"type"=>"BigDecimal"},
        "comments" => {"type"=>"String"},
        "createdByID" => {"type"=>"String"},
        "createdDate" => {"type"=>"Date"},
        "dueDate" => {"type"=>"Date"},
        "id" => {"type"=>"String"},
        "includesOneTime" => {"type"=>"Boolean"},
        "includesRecurring" => {"type"=>"Boolean"},
        "includesUsage" => {"type"=>"Boolean"},
        "invoiceDate" => {"type"=>"Date"},
        "invoiceNumber" => {"type"=>"String"},
        "lastEmailSentDate" => {"type"=>"Date"},
        "paymentAmount" => {"type"=>"BigDecimal"},
        "postedBy" => {"type"=>"String"},
        "postedDate" => {"type"=>"Date"},
        "refundAmount" => {"type"=>"BigDecimal"},
        "source" => {"type"=>"String"},
        "sourceID" => {"type"=>"String"},
        "status" => {"type"=>"String"},
        "targetDate" => {"type"=>"Date"},
        "taxAmount" => {"type"=>"BigDecimal"},
        "taxExemptAmount" => {"type"=>"BigDecimal"},
        "transferredtoAccounting" => {"type"=>"Boolean"},
        "updatedByID" => {"type"=>"String"},
        "updatedDate" => {"type"=>"Date"}
      }
    },
    "invoiceItem" => {
      "isRoot" => true,
      "fields" =>{
        "account" => {"type"=>"account","belong_to"=>true},
        "accountingCode" => {"type"=>"String"},
        "amendment" => {"type"=>"amendment"},
        "appliedToInvoiceItemId" => {"type"=>"String"},
        "billTo" => {"type"=>"contact"},
        "chargeAmount" => {"type"=>"BigDecimal"},
        "chargeDate" => {"type"=>"Date"},
        "chargeName" => {"type"=>"String"},
        "createdByID" => {"type"=>"String"},
        "createdDate" => {"type"=>"Date"},
        "defaultPaymentMethod" => {"type"=>"paymentMethod"},
        "id" => {"type"=>"String"},
        "invoice" => {"type"=>"invoice","belong_to"=>true},
        "parentAccount" => {"type"=>"account","spread"=>false},
        "processingType" => {"type"=>"String"},
        "product" => {"type"=>"product"},
        "productRatePlan" => {"type"=>"productRatePlan"},
        "productRatePlanCharge" => {"type"=>"productRatePlanCharge"},
        "quantity" => {"type"=>"Integer"},
        "ratePlan" => {"type"=>"ratePlan"},
        "ratePlanCharge" => {"type"=>"ratePlanCharge"},
        "revenueRecognitionStartDate" => {"type"=>"Date"},
        "serviceEndDate" => {"type"=>"Date"},
        "serviceStartDate" => {"type"=>"Date"},
        "sku" => {"type"=>"String"},
        "soldTo" => {"type"=>"contact"},
        "subscription" => {"type"=>"subscription"},
        "subscriptionID" => {"type"=>"String"},
        "taxAmount" => {"type"=>"BigDecimal"},
        "taxCode" => {"type"=>"String"},
        "taxExemptAmount" => {"type"=>"BigDecimal"},
        "unitPrice" => {"type"=>"BigDecimal"},
        "uom" => {"type"=>"String"},
        "updatedByID" => {"type"=>"String"},
        "updatedDate" => {"type"=>"Date"}
      }
    },
    "paymentMethod" => {
      "isRoot" => false,
      "fields" => {
        "accountID" => {"type"=>"String"},
        "achABACode" => {"type"=>"String"},
        "achAccountName" => {"type"=>"String"},
        "achAccountNumberMask" => {"type"=>"String"},
        "achAccountType" => {"type"=>"String"},
        "achBankName" => {"type"=>"String"},
        "active" => {"type"=>"Boolean"},
        "bankBranchCode" => {"type"=>"String"},
        "bankCheckDigit" => {"type"=>"String"},
        "bankCity" => {"type"=>"String"},
        "bankCode" => {"type"=>"String"},
        "bankIdentificationNumber" => {"type"=>"String"},
        "bankName" => {"type"=>"String"},
        "bankPostalCode" => {"type"=>"String"},
        "bankStreetName" => {"type"=>"String"},
        "bankStreetNumber" => {"type"=>"String"},
        "bankTransferAccountName" => {"type"=>"String"},
        "bankTransferAccountNumberMask" => {"type"=>"String"},
        "bankTransferAccountType" => {"type"=>"String"},
        "bankTransferType" => {"type"=>"String"},
        "businessIdentificationCode" => {"type"=>"String"},
        "city" => {"type"=>"String"},
        "country" => {"type"=>"String"},
        "createdByID" => {"type"=>"String"},
        "createdDate" => {"type"=>"Date"},
        "creditCardAddress1" => {"type"=>"String"},
        "creditCardAddress2" => {"type"=>"String"},
        "creditCardCity" => {"type"=>"String"},
        "creditCardCountry" => {"type"=>"String"},
        "creditCardExpirationMonth" => {"type"=>"Integer"},
        "creditCardExpirationYear" => {"type"=>"Integer"},
        "creditCardHolderName" => {"type"=>"String"},
        "creditCardMaskNumber" => {"type"=>"String"},
        "creditCardPostalCode" => {"type"=>"String"},
        "creditCardState" => {"type"=>"String"},
        "creditCardType" => {"type"=>"String"},
        "deviceSessionID" => {"type"=>"String"},
        "email" => {"type"=>"String"},
        "existingMandate" => {"type"=>"String"},
        "firstName" => {"type"=>"String"},
        "iban" => {"type"=>"String"},
        "id" => {"type"=>"String"},
        "ipAddress" => {"type"=>"String"},
        "lastFailedSaleTransactionDate" => {"type"=>"String"},
        "lastName" => {"type"=>"String"},
        "lastTransactionDate" => {"type"=>"Date"},
        "lastTransactionStatus" => {"type"=>"String"},
        "mandateCreationDate" => {"type"=>"String"},
        "mandateID" => {"type"=>"String"},
        "mandateReceived" => {"type"=>"String"},
        "mandateUpdateDate" => {"type"=>"String"},
        "maxConsecutivePaymentFailures" => {"type"=>"Integer"},
        "name" => {"type"=>"String"},
        "numberofConsecutiveFailures" => {"type"=>"Integer"},
        "paymentMethodStatus" => {"type"=>"String"},
        "paymentRetryWindow" => {"type"=>"String"},
        "paypalBAID" => {"type"=>"String"},
        "paypalEmail" => {"type"=>"String"},
        "paypalPreapprovalKey" => {"type"=>"String"},
        "paypalType" => {"type"=>"String"},
        "phone" => {"type"=>"String"},
        "postalCode" => {"type"=>"String"},
        "state" => {"type"=>"String"},
        "streetName" => {"type"=>"String"},
        "streetNumber" => {"type"=>"String"},
        "tokenID" => {"type"=>"String"},
        "totalNumberOfErrorPayments" => {"type"=>"Integer"},
        "totalNumberOfProcessedPayments" => {"type"=>"Integer"},
        "type" => {"type"=>"String"},
        "updatedByID" => {"type"=>"String"},
        "updatedDate" => {"type"=>"Date"},
        "useDefaultRetryRule" => {"type"=>"Boolean"}
      }
    },
    "product" => {
      "isRoot" => true,
      "fields" => {
        "createdByID" => {"type"=>"String"},
        "createdDate" => {"type"=>"Date"},
        "description" => {"type"=>"String"},
        "effectiveEndDate" => {"type"=>"Date"},
        "effectiveStartDate" => {"type"=>"Date"},
        "id" => {"type"=>"String"},
        "name" => {"type"=>"String"},
        "sku" => {"type"=>"String"},
        "updatedByID" => {"type"=>"String"},
        "updatedDate" => {"type"=>"Date"}
      }
    },
    "productRatePlan" => {
      "isRoot" => false,
      "fields" => {
        "createdByID" => {"type"=>"String"},
        "createdDate" => {"type"=>"Date"},
        "description" => {"type"=>"String"},
        "effectiveEndDate" => {"type"=>"Date"},
        "effectiveStartDate" => {"type"=>"Date"},
        "id" => {"type"=>"String"},
        "name" => {"type"=>"String"},
        "updatedByID" => {"type"=>"String"},
        "updatedDate" => {"type"=>"Date"}
      }
    },
    "productRatePlanCharge" => {
      "isRoot" => false,
      "fields" => {
        "accountingCode" => {"type"=>"String"},
        "applyDiscountTo" => {"type"=>"String"},
        "billCycleDay" => {"type"=>"String"},
        "billCycleType" => {"type"=>"String"},
        "billingPeriod" => {"type"=>"String"},
        "billingPeriodAlignment" => {"type"=>"String"},
        "chargeModel" => {"type"=>"String"},
        "chargeType" => {"type"=>"String"},
        "createdByID" => {"type"=>"String"},
        "createdDate" => {"type"=>"Date"},
        "defaultQuantity" => {"type"=>"Integer"},
        "deferredRevenueAccount" => {"type"=>"String"},
        "description" => {"type"=>"String"},
        "discountLevel" => {"type"=>"String"},
        "id" => {"type"=>"String"},
        "includedUnits" => {"type"=>"BigDecimal"},
        "legacyRevenueReporting" => {"type"=>"Boolean"},
        "maxQuantity" => {"type"=>"Integer"},
        "minQuantity" => {"type"=>"Integer"},
        "name" => {"type"=>"String"},
        "numberOfPeriod" => {"type"=>"Integer"},
        "overageCalculationOption" => {"type"=>"String"},
        "overageUnusedUnitsCreditOption" => {"type"=>"String"},
        "priceChangeOption" => {"type"=>"String"},
        "priceIncreasePercentage" => {"type"=>"BigDecimal"},
        "recognizedRevenueAccount" => {"type"=>"String"},
        "revenueRecognitionCode" => {"type"=>"String"},
        "revenueRecognitionRuleName" => {"type"=>"String"},
        "revenueRecognitionTrigger" => {"type"=>"String"},
        "smoothingModel" => {"type"=>"String"},
        "specificBillingPeriod" => {"type"=>"String"},
        "taxCode" => {"type"=>"String"},
        "taxMode" => {"type"=>"String"},
        "taxable" => {"type"=>"Boolean"},
        "triggerEvent" => {"type"=>"String"},
        "uom" => {"type"=>"String"},
        "upToHowManyPeriods" => {"type"=>"Integer"},
        "updatedByID" => {"type"=>"String"},
        "updatedDate" => {"type"=>"Date"},
        "useDiscountSpecificAccountingCode" => {"type"=>"String"},
        "useTenantDefaultForPriceChange" => {"type"=>"Boolean"}
      }
    },
    "ratePlan" => {
      "isRoot" => false,
      "fields" => {
        "amendmentType" => {"type"=>"String"},
        "createdByID" => {"type"=>"String"},
        "createdDate" => {"type"=>"Date"},
        "id" => {"type"=>"String"},
        "name" => {"type"=>"String"},
        "updatedByID" => {"type"=>"String"},
        "updatedDate" => {"type"=>"Date"}
      }
    },
    "ratePlanCharge" => {
      "isRoot" => false,
      "fields" => {
        "accountingCode" => {"type"=>"String"},
        "applyDiscountTo" => {"type"=>"String"},
        "billCycleDay" => {"type"=>"Integer"},
        "billCycleType" => {"type"=>"String"},
        "billingPeriod" => {"type"=>"String"},
        "billingPeriodAlignment" => {"type"=>"String"},
        "chargeModel" => {"type"=>"String"},
        "chargeNumber" => {"type"=>"String"},
        "chargeType" => {"type"=>"String"},
        "chargedThroughDate" => {"type"=>"Date"},
        "createdByID" => {"type"=>"String"},
        "createdDate" => {"type"=>"Date"},
        "description" => {"type"=>"String"},
        "discountLevel" => {"type"=>"String"},
        "dmrc" => {"type"=>"BigDecimal"},
        "dtcv" => {"type"=>"BigDecimal"},
        "effectiveEndDate" => {"type"=>"Date"},
        "effectiveStartDate" => {"type"=>"Date"},
        "id" => {"type"=>"String"},
        "isLastSegment" => {"type"=>"Boolean"},
        "listprice" => {"type"=>"BigDecimal"},
        "locationID" => {"type"=>"String"},
        "locationName" => {"type"=>"String"},
        "mrr" => {"type"=>"BigDecimal"},
        "name" => {"type"=>"String"},
        "numberofPeriods" => {"type"=>"Integer"},
        "originalID" => {"type"=>"String"},
        "overageCalculationOption" => {"type"=>"String"},
        "overageUnusedUnitsCreditOption" => {"type"=>"String"},
        "processedThroughDate" => {"type"=>"Date"},
        "promoamount" => {"type"=>"BigDecimal"},
        "promocode" => {"type"=>"String"},
        "quantity" => {"type"=>"Integer"},
        "revenueRecognitionCode" => {"type"=>"String"},
        "revenueRecognitionRuleName" => {"type"=>"String"},
        "revenueRecognitionTriggerCondition" => {"type"=>"String"},
        "segment" => {"type"=>"Integer"},
        "specificBillingPeriod" => {"type"=>"String"},
        "taProductDescription" => {"type"=>"String"},
        "taSubscriptionLevel" => {"type"=>"String"},
        "tcv" => {"type"=>"BigDecimal"},
        "trialduration" => {"type"=>"String"},
        "triggerDate" => {"type"=>"Date"},
        "triggerEvent" => {"type"=>"String"},
        "unitofMeasure" => {"type"=>"String"},
        "upToPeriods" => {"type"=>"String"},
        "updatedByID" => {"type"=>"String"},
        "updatedDate" => {"type"=>"Date"},
        "version" => {"type"=>"Integer"}
      }
    },
    "subscription" => {
      "isRoot" => false,
      "fields" => {
        "account" => {"type"=>"account","belong_to"=>true},
        "autoRenew" => {"type"=>"Boolean"},
        "autoRenewLock" => {"type"=>"String"},
        "billTo" => {"type"=>"contact"},
        "cancelReason" => {"type"=>"String"},
        "cancelledDate" => {"type"=>"Date"},
        "channel" => {"type"=>"String"},
        "contractAcceptanceDate" => {"type"=>"Date"},
        "contractEffectiveDate" => {"type"=>"Date"},
        "createdByID" => {"type"=>"String"},
        "createdDate" => {"type"=>"Date"},
        "creatorAccountID" => {"type"=>"String"},
        "creatorInvoiceOwnerID" => {"type"=>"String"},
        "defaultPaymentMethod" => {"type" => "paymentMethod"},
        "id" => {"type"=>"String"},
        "initialTerm" => {"type"=>"Integer"},
        "invoiceOwnerID" => {"type"=>"String"},
        "invoiceSeparate" => {"type"=>"Boolean"},
        "locationID" => {"type"=>"String"},
        "name" => {"type"=>"String"},
        "notes" => {"type"=>"String"},
        "orderNumber" => {"type"=>"String"},
        "originalCreatedDate" => {"type"=>"Date"},
        "originalID" => {"type"=>"String"},
        "parentAccount" => {"type"=>"account"},
        "previousSubscriptionID" => {"type"=>"String"},
        "renewalTerm" => {"type"=>"Integer"},
        "serviceActivationDate" => {"type"=>"Date"},
        "smartrenew" => {"type"=>"String"},
        "smartrenewprocessed" => {"type"=>"String"},
        "soldTo" => {"type"=>"contact"},
        "ssc" => {"type"=>"String"},
        "status" => {"type"=>"String"},
        "subchannel" => {"type"=>"String"},
        "subscriptionEndDate" => {"type"=>"Date"},
        "subscriptionStartDate" => {"type"=>"Date"},
        "subscriptionVersionAmendment" => {"type"=>"amendment"},
        "termEndDate" => {"type"=>"Date"},
        "termStartDate" => {"type"=>"Date"},
        "termType" => {"type"=>"String"},
        "updatedByID" => {"type"=>"String"},
        "updatedDate" => {"type"=>"Date"},
        "version" => {"type"=>"Integer"}
      }
    }
  }
  M = Metas.new(META_DEFS)
end
