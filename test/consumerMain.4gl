Import com
Import util

Type
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
END RECORD

Main
  Define
    newFreq tyPF,
    jsonStr String

  Menu "Pools"
    Command "Nb Pools"
      Display doRequest("http://127.0.0.1:8099/poolService/pools/count")

    Command "PoolName"
      --WSQuery
      Display doRequest("http://127.0.0.1:8099/poolService/pools/name?id=3")

    Command "isOpen"
      --WSParam
      Display doRequest("http://127.0.0.1:8099/poolService/pools/2/isopen")

    Command "newFreq"
      Let newFreq.fields.sigid = doRequest("http://127.0.0.1:8099/poolService/pools/idsurfs?id=2")
      Display "Client: ",newFreq.fields.sigid
      Let newFreq.fields.isopen = True
      Let newFreq.fields.occupation = 30
      Let jsonStr = util.JSONObject.fromFGL(newFreq).toString()

      Display doPostRequest("http://127.0.0.1:8099/poolService/pools/addfreq", jsonStr )

    Command "Exit"
      Exit Menu
  End Menu

End Main

Function doRequest( urlStr String )
  Define
    url    com.HttpRequest,
    ans    com.HttpResponse,
    ret    smallInt,
    i      Integer

      Let url = com.HttpRequest.Create(urlStr)
      Call url.setMethod("GET")
      Call url.doRequest()

      Let ans = url.getResponse()
      --If ans.getStatusCode() == 200 Then
        Display ans.getStatusCode()
        Display "Headers"
        For i=1 To ans.getHeaderCount()
          Display ans.getHeaderName(i)," = ",ans.getHeaderValue(i)
        End For
        Display "Body"
        Return ans.getTextResponse()
      --Else
      --End If
End Function

Function doPostRequest( urlStr String, dataStr String )
  Define
    url    com.HttpRequest,
    ans    com.HttpResponse,
    ret    smallInt,
    i      Integer

      Let url = com.HttpRequest.Create(urlStr)
      Call url.setMethod("POST")
      Display "Client: ",dataStr
      Call url.doTextRequest(dataStr)

      Let ans = url.getResponse()
        Display ans.getStatusCode()
        Display "Headers"
        For i=1 To ans.getHeaderCount()
          Display ans.getHeaderName(i)," = ",ans.getHeaderValue(i)
        End For
        Display "Body"
        Return ans.getTextResponse()
End Function