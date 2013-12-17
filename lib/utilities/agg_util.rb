module AggUtil
  def total_invoice_amount
    agg_param=[
      {"$match" => { "$and"=>[
            {"invoice.status"=> "Posted"},
            {"processingType"=> {"$in"=>["Charge","Discount","Tax"]}}
          ] } },
      { "$project" => {
          "eAmount" => {"$cond"=>[{"$eq"=>["$processingType","Tax"]},"$taxAmount","$chargeAmount"]},
          "currency"  => "$account.currency",
          "_id"=>0
        }},
      { "$group" => { "_id" => {"currency"=>"$currency"},"total"=>{"$sum"=>"$eAmount"}}},
      { "$project" => {
          "currency" => "$_id.currency",
          "totalAmount" => "$total",
          "_id"=>0
        }}
    ]

    @collection.aggregate(agg_param)
  end

  def average_invoice_amount
    agg_param=[
        {"$match" => { "$and"=>[
              {"invoice.status"=> "Posted"}
            ] } },
        { "$project" => {
            "invId" => "$invoice.id",
            "invAmount" => "$invoice.amount",
            "currency"  => "$account.currency",
            "_id"=>0
          }},
        { "$group" => { "_id" => {"invId"=>"$invId","invAmount"=>"$invAmount","currency"=>"$currency"}} },
        { "$group" => { "_id" => {"currency"=>"$_id.currency"},"total"=>{"$sum"=>"$_id.invAmount"},"count"=>{"$sum"=>1}}},
        { "$project" => {
            "currency" => "$_id.currency",
            "total" => "$total",
            "count" => "$count",
            "avg" => {"$divide"=>["$total","$count"]},
            "_id"=>0
          }}
      ]

    @collection.aggregate(agg_param)
  end

  def cumulative_invoice_amount(start_date_utc, end_date_utc)
    agg_param=[
      {"$match" => { "$and"=>[
            {"invoice.status"=> "Posted"},
            {"invoice.invoiceDate"=>{"$gt"=> start_date_utc}},
            {"invoice.invoiceDate"=>{"$lt"=> end_date_utc}}
          ] } },
      { "$project" => {
          "invId" => "$invoice.id",
          "invAmount" => "$invoice.amount",
          "currency"  => "$account.currency",
          "_id"=>0
        }},
      { "$group" => { "_id" => {"invId"=>"$invId","invAmount"=>"$invAmount","currency"=>"$currency"}} },
      { "$group" => { "_id" => {"currency"=>"$_id.currency"},"total"=>{"$sum"=>"$_id.invAmount"}} },
      { "$project" => {
          "currency" => "$_id.currency",
          "total" => "$total",
          "_id"=>0
        }},
    ]

    @collection.aggregate(agg_param)
  end
end

