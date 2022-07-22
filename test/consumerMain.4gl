Import com
Import util

Type
  tyPool RECORD
	imageurl String,
	name String,
	isopen String,
	occupation Integer
  END RECORD

Main
  Define
    pool tyPool,
    nbPools Integer,
    curPool Integer

  Open Form f1 From "poolGrid"
  Display Form f1

    Try
      Let nbPools = doRequest("http://127.0.0.1:8099/poolService/pools/count")
    Catch
      Call showMsg("Pfff","font:FontAwesome.ttf:f119","The service is not online")
      Exit Program
    End Try
    If nbPools = 0 Then
      Call showMsg("Pfff","font:FontAwesome.ttf:f119","No pool in this town")
      Exit Program
    End If

    Let curPool = 1
    Call showPool(curPool)

    Menu "Pools"
      Before Menu
        Call Dialog.setActionActive("previous",False)

      On Action previous
        Let curPool = curPool - 1
        Call Dialog.setActionActive("next",True)
        If curPool = 1 Then
          Call Dialog.setActionActive("previous",False)
        End If
        Call showPool(curPool)

      On Action next
        Let curPool = curPool + 1
        Call Dialog.setActionActive("previous",True)
        If curPool = nbPools Then
          Call Dialog.setActionActive("next",False)
        End If
        Call showPool(curPool)

      On Action close
        Exit Menu

    End Menu

--    Command "newFreq"
--      Let newFreq.fields.sigid = doRequest("http://127.0.0.1:8099/poolService/pools/idsurfs?id=2")
--      Display "Client: ",newFreq.fields.sigid
--      Let newFreq.fields.isopen = True
--      Let newFreq.fields.occupation = 30
--      Let jsonStr = util.JSONObject.fromFGL(newFreq).toString()
--
--      Display doPostRequest("http://127.0.0.1:8099/poolService/pools/addfreq", jsonStr )

End Main

Function showPool( poolNo Integer )
  Define
    pool tyPool

  Let pool.name = doRequest( Sfmt("http://127.0.0.1:8099/poolService/pools/name?id=%1",poolNo) )
  Let pool.imageurl = doRequest( Sfmt("http://127.0.0.1:8099/poolService/pools/image?id=%1",poolNo) )
  Case doRequest( Sfmt("http://127.0.0.1:8099/poolService/pools/%1/isopen",poolNo) )
    When 0
      Let pool.isOpen = "font:FontAwesome.ttf:f05c:red"
    When 1
      Let pool.isOpen = "font:FontAwesome.ttf:f05d:green"
    Otherwise
      Let pool.isOpen = "font:FontAwesome.ttf:f059:blue"
  End Case
  Let pool.occupation = doRequest( Sfmt("http://127.0.0.1:8099/poolService/pools/%1/crowd",poolNo) )
  Display By Name pool.*
End Function

Function showMsg( ttl String,img String,msg String )
  Menu ttl
    Attributes (
      Style="dialog",
      Image=img,
      Comment=msg
    )

    Command "Ok"
      Exit Menu
  End Menu
End Function

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