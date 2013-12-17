include DBClient

module LogProcessor
  def process_one_log(mongo_client, tenant_name,id)
    tItem = find_one_transaction(mongo_client, tenant_name, id)
    opItem = Converter.convert(tItem)
    execute(mongo_client, opItem)
  end
end