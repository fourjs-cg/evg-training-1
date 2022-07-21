Import com
Import util

Type
  tyPools DYNAMIC ARRAY OF RECORD
    datasetid STRING,
    recordid STRING,
    fields RECORD
        accessforelder FLOAT,
        exceptions STRING,
        accessforblind FLOAT,
        name STRING,
        address STRING,
        idsurfs STRING,
        serviceandactivities STRING,
        additionalinformation STRING,
        normalizedalias STRING,
        instagramurl STRING,
        images STRING,
        accessfordeaf FLOAT,
        accessforwheelchair FLOAT,
        exceptionalschedule STRING,
        phone STRING,
        mail STRING,
        description STRING,
        access STRING,
        point_geo DYNAMIC ARRAY OF FLOAT,
        characteristics STRING,
        friendlyurl STRING,
        schedulelinkname STRING,
        imageurl STRING,
        instagramname STRING,
        schedulelinkurl STRING,
        periods STRING,
        hasurlschedule FLOAT,
        accessfordeficient FLOAT,
        websitename STRING,
        facebookname STRING,
        websiteurl STRING,
        facebookurl STRING,
        accessfordisabled STRING
    END RECORD,
    geometry RECORD
        type STRING,
        coordinates DYNAMIC ARRAY OF FLOAT
    END RECORD,
    record_timestamp STRING
END RECORD,
  tyPF RECORD
    datasetid STRING,
    recordid STRING,
    fields RECORD
        occupation FLOAT,
        isopen FLOAT,
        sigid STRING,
        name STRING,
        dayschedule STRING,
        realtimestatus STRING,
        types STRING,
        updatedate STRING
    END RECORD,
    record_timestamp STRING
END RECORD,
  tyPoolFrequentation DYNAMIC ARRAY OF tyPF,
  tyPoolFreq Record
    name String,
    address String,
    isOpen String,
    occupation Integer
  End Record

Define
    pools tyPools,
    poolFrequentation tyPoolFrequentation

Public Function init()
  Define
    fileId base.Channel,
    jsonStr String,
    poolFreq Dynamic Array Of tyPoolFreq,
    i,j Integer

  Let fileId = base.Channel.create()
  Call fileId.openFile("lieux_piscines.json","r")
  Let jsonStr = fileId.readLine()
  Call fileId.close()
  --Display util.JSON.proposeType( jsonStr )
  Call util.JSON.parse( jsonStr, pools )

  Let fileId = base.Channel.create()
  Call fileId.openFile("frequentation-en-temps-reel-des-piscines.json","r")
  Let jsonStr = fileId.readLine()
  Call fileId.close()
  Call util.JSON.parse( jsonStr, poolFrequentation )
End Function

Public Function nbPools()
  Attributes (WSGet,
              WSPath="/pools/count",
              WSDescription="Returns the number of pools in SXB")
  Returns Integer

  Return pools.getLength()
End Function

Public Function getPoolName( poolId Integer Attributes (WSQuery,WSName="id") )
  Attributes (WSGet,
              WSPath="/pools/name",
              WSDescription="Returns the name of the pool")
  Returns String

  Return pools[poolId].fields.name
End Function

Public Function getPoolIdsurfs( poolId Integer Attributes (WSQuery,WSName="id") )
  Attributes (WSGet,
              WSPath="/pools/idsurfs",
              WSDescription="Returns the id of the pool")
  Returns String

  Return pools[poolId].fields.idsurfs
End Function

Public Function postPoolFreq( jsonNewFreq String )
  Attributes (WSPost,
              WSPath="/pools/addfreq",
              WSDescription="Add a pool frequentation")
  Returns Boolean

  Define
    poolFreq tyPF,
    jsonObjId util.JSONObject

  Display "Server ",jsonNewFreq
  Let jsonObjId = util.JSONObject.parse(jsonNewFreq)
  Call jsonObjId.toFGL(poolFreq)

  Call poolFrequentation.appendElement()
  Let poolFrequentation[poolFrequentation.getLength()] = poolFreq

  Return true
End Function

Public Function isPoolOpen( poolId Integer Attributes (WSParam) )
  Attributes (WSGet,
              WSPath="/pools/{poolId}/isopen",
              WSDescription="Returns the name of the pool")
  Returns Boolean

  Define
    isOpen Boolean

  Let isOpen = poolFrequentation[searchRow( pools[poolId].fields.idsurfs )].fields.isopen
  Return NVL(isOpen,False)
End Function

Function searchRow( keyval String )
         Returns Integer

  Define
    i Integer

  For i=1 To poolFrequentation.getLength()
    If poolFrequentation[i].fields.sigid = keyval Then
      Exit For
    End If
  End For
  If i=poolFrequentation.getLength() 
     And poolFrequentation[i].fields.sigid <> keyval 
  Then
    Let i = 0
  End If

  Return i
End Function