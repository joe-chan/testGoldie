module DBClient
  def execute(mongo_client,opItem)
    return if not opItem
    db = mongo_client.db(opItem["db"])
    meta = Metas::M.item(opItem["type"])
    doc = opItem["doc"]

    send(opItem['operation'],opItem,db,meta,doc)
  end

  def find_one_transaction(mongo_client,db_name,id)
    db=mongo_client.db(db_name)
    coll=db.collection('transaction')
    obj=coll.find({"_id"=>BSON::ObjectId(id)})
    obj.next
  end

  private
  ############################## delete related ###############################

  def delete(opItem,db,meta,doc)
    if meta.isRoot? # update root document
      deleteRoot meta.name, doc, db
    end

    meta.linksInChild.each do |ref|
      deleteChild(ref,doc,db)
    end
  end

  def deleteRoot(collName,doc,db)
    coll = db.collection(collName)
    fieldRef="id"
    filter={}
    filter[fieldRef]=doc["id"]

    puts "delete #{collName} where #{filter}"
    coll.remove(filter)
  end

  def deleteChild(ref,doc, db)
    collectionAndField = to_coll_field(ref)
    collection = collectionAndField[:collection]
    fieldName = collectionAndField[:fieldName]

    if not Metas::M.item(collection).isRoot then
      return
    end

    coll = db.collection(collection)

    fieldRef=""<<fieldName<<".id"
    filter={}
    filter[fieldRef]=doc["id"]

    puts "delete #{collection} where #{filter}"
    coll.remove(filter)
  end

  ############################## insert related ###############################
  def insert(opItem,db,meta,doc)
    coll = db.collection(meta.name)
    coll.insert(doc)
  end
  ############################## update related ###############################
  def update(opItem,db,meta,doc)
    if meta.isRoot? # update root document
      updateRoot meta.name, doc, db
    end

    meta.inRefs.each do |ref| # have to consider the case of BillTo and SoldTo we can use one update? is it possible ?
      updateEmbedded ref, doc, db
    end
  end

  def updateRoot(collName,doc,db)
    coll = db.collection(collName)
    fieldRef="id"
    filter={}
    filter[fieldRef]=doc["id"]

    update={}
    updateItems={}
    buildUpdate('',doc,updateItems,true)
    update["$set"]=updateItems

    puts "update #{collName} where #{filter} and set #{update}"
    puts ""
    coll.update(filter,update, {:multi => true})

  end

  def updateEmbedded(refDef,doc, db)
    ref=refDef[:path]
    spread=refDef[:spread]
    collectionAndField = to_coll_field(ref)
    collection = collectionAndField[:collection]
    fieldName = collectionAndField[:fieldName]

    if not Metas::M.item(collection).isRoot then
      return
    end

    coll = db.collection(collection)

    fieldRef=""<<fieldName<<".id"
    filter={}
    filter[fieldRef]=doc["id"]

    update={}
    updateItems={}
    buildUpdate(fieldName,doc,updateItems,spread)
    update["$set"]=updateItems

    puts "update #{collection} where #{filter} and set #{update}"
    puts ""
    coll.update(filter,update, {:multi => true})
  end

  def buildUpdate(fName,doc,r,spread)
    result={}
    result=r if r
    doc.each do |key,value| #handle nest like Account.BillTo later
      if key=="id"
        next
      end
      if value.instance_of? Hash then
        if spread
          result[key]=value
        end
      elsif
        temp=""
        if fName && fName.size()>0 then
          temp<<fName<<"."
        end
        kk=temp<<key
        result[kk]=value
      end
    end
  end
  ############################## utils related ###############################
  def to_coll_field(collAndField)
    collection_and_field = collAndField.split('.')
    collection = collection_and_field[0]
    field_name = collection_and_field[1]
    return :collection=>collection, :fieldName=>field_name
  end
end