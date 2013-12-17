module DataSources
    INVOICEITEM_DATASOURCE_NAME = "invoiceItem"
    ACCOUNT_DATASOURCE_NAME = "account"
    TRANSACTION_DATASOURCE_NAME = "transaction"

    INVOICEITEM_OBJECTS = ["invoice", "account", "parentAccount",
      "billTo", "soldTo", "defaultPaymentMethod",
      "ratePlanCharge", "ratePlan", "subscription", "amendment",
      "productRatePlanCharge", "productRatePlan", "product"]
    ACCOUNT_OBJECTS = ["billTo", "defaultPaymentMethod", "soldTo", "parentAccount"]
end