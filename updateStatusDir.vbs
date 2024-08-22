 ' updateStatusDir.vbs - обновление статусов обработки ЭСЧФ НДС в каталоге

 ' Использование:
 ' "cscript updateStatusDir.vbs <url АС портала> <папка для хранения документов> <тип документа>"
  
  dim oFSO
 ' dim EVatService
  dim EDocStatus
  dim res
  dim FolderName
  dim dt
  dim docType, sgnPattern
  dim prxy_url, prxy_port, prxy_user, prxy_pass, prxy_type, prxy_msg
  dim unp, pubKeyId, pwd, connectStr, loginFlags
  dim read_timeout
  dim progName, progVersion, compVersion

  progName = "updateStatus"
  Set wshShell = CreateObject( "WScript.Shell" )
  progVersion = GetEnvVar("SIMPLE_APP_VERSION", "1.0.0")
  
  set objArgs = WScript.Arguments
  if objArgs.count < 3 then
     WScript.Echo "ЭСЧФ simpleapp." & progName &". Версия " & progVersion
	 WScript.Echo "Обновление статусов обработки ЭСЧФ НДС в каталоге"
     WScript.Echo "Использование:"
     WScript.Echo "cscript updateStatusDir.vbs <url АС портала> <папка для хранения документов> <тип документа>"
     WScript.Quit
  end if

  progName = objArgs(0)
  url = objArgs(1)
  FolderName = objArgs(2)
  docType = objArgs(3)

  WScript.Echo "ЭСЧФ simpleapp." & progName &". Версия " & progVersion  
  
  prxy_url = GetEnvVar("PROXY_URL", "")
  prxy_port = GetEnvVar("PROXY_PORT", 0)
  prxy_user = GetEnvVar("PROXY_USER", "")
  prxy_pass = GetEnvVar("PROXY_PASS", "")
  prxy_type = GetEnvVar("PROXY_TYPE", 1)

  read_timeout = GetEnvVar("READ_TIMEOUT", "")
  
  unp = GetEnvVar("UNP", "")
  pubKeyId = GetEnvVar("PUBLIC_KEY_ID", "")
  pwd = GetEnvVar("PASSWORD", "")
  
  connectStr = ""
  loginFlags = 0  
  if unp <> "" then
    if len(connectStr) > 0 then
       connectStr = ";UNP=" & unp
    else
      connectStr = "UNP=" & unp
    end if 
    loginFlags = &h40
  end if
  if pubKeyId <> "" then
    if len(connectStr) > 0 then
       connectStr = ";PUB_KEY_ID=" & pubKeyId
    else
      connectStr = "PUB_KEY_ID=" & pubKeyId
    end if 
    loginFlags = &h40
  end if
  if pwd <> "" then
    if len(connectStr) > 0 then
       connectStr = connectStr & ";PASSWORD_KEY=" & pwd
    else
       connectStr = connectStr & "PASSWORD_KEY=" & pwd
    end if 
  end if

  
  sgnPattern = "\." & docType & "\.xml$"
  
  'Создание COM object EInvVatService.Connector
  'set EVatService = CreateObject("EInvVatService.Connector")
  'if read_timeout <> "" then
  '   res = EVatService.SetServiceProperty( "connection.readTimeout", read_timeout, 0 )
  '   if res <> 0 then
  '     WScript.Echo "Ошибка установки таймаута сетевого чтения: " & EVatService.LastError & " (    0x" & Hex(res) & ")"
  '     WScript.Quit
  '   end if    
  'end if
  
  'compVersion = EVatService.Version
  'WScript.Echo "Версия компонента EInvVatService " & compVersion  
  
  'Создание COM object для чтения файлов
  Set oFSO = CreateObject("Scripting.FileSystemObject")
  
  'res = EVatService.Login(connectStr, loginFlags)
  'if res = 0 then
  '   WScript.Echo "Авторизация успешна"
  'else
  '   WScript.Echo "Ошибка авторизации: " & EVatService.LastError & " (    0x" & Hex(res) & ")"
  '   WScript.Quit
  'end if

  'if prxy_url <> "" and prxy_url <> "%PROXY_URL%" then
  '   if EVatService.SetProxy(prxy_url, prxy_port, prxy_user, prxy_pass, prxy_type) <> 0 then
  '      WScript.Echo "Ошибка установки прокси: " & EVatService.LastError
  '      WScript.Quit
  '   end if
  '   prxy_msg = " через прокси " & prxy_url & ":" & prxy_port
  'end if

  'WScript.Echo "Подключение   " & url & prxy_msg
  'res = EVatService.Connect(url)
  'if res = 0 then
  '   WScript.Echo "Подключение успешно"
  'else
  '   WScript.Echo "Ошибка подключения: " & EVatService.LastError & " (    0x" & Hex(res) & ")"
  '   WScript.Quit
  'end if 
  
  RefreshFolder FolderName, sgnPattern
  'if EVatService.Disconnect <> 0 then
  '   WScript.Echo "Ошибка при завершении подключения к службе регистрации"
  'end if
  
  'if EVatService.Logout <> 0 then
  '   WScript.Echo "Ошибка при завершении авторизованной сессии"
  'end if  
  
  'конец программы
  
  
  sub RefreshFolder(FolderName, sgnPattern)
  dim objFolder
	dim colFiles
  dim col1F
  dim colstats
	dim invoiceFileName
	dim InvVatXml
	dim lastStatus
	dim invVatNumber
	dim refresh 
  dim donemove
	dim myRegExp
	dim cnt
  dim basecol 
  dim f1
  dim colfin
  dim coltomove

	cnt = 0
	
	Set objFolder = oFSO.GetFolder(FolderName)
	Set colFiles = objFolder.Files
  
  For Each f1 in colFiles
    basecol = basecol & CStr(f1.name) & " "
    Next
    
  basecol = split(basecol)

  col1F = Filter(basecol, "sgn")
  colstats = Filter(basecol, "-status-")
  
	For Each objFile in col1F
    
			invoiceFileName = objFile
					
			cnt = cnt + 1
			'set InvVatXml = EVatService.CreateEDoc
			'res = InvVatXml.LoadFromFile(CStr(objFolder.Path & "\" & objFile))
			'if res <> 0 then
			'   WScript.Echo "Ошибка чтения файла: " & EVatService.LastError & " (    0x" & Hex(res) & ")"
			'else
			
				'invVatNumber = InvVatXml.Document.GetXmlNodeValue("issuance/general/number") 
				
				'lastStatus = FindLastStatusFor(invVatNumber, colFiles)
				invVatNumber = Mid(invoiceFileName,9, 25)
        colfin = Filter(colstats, "invoice-" & invVatNumber)
        lastStatus = FindLastStatusFor(invVatNumber, colfin, objFolder)

				refresh = 0
				donemove = 0
				if lastStatus = "" then
					refresh = 1
				'ЭСЧФ создан, подписан отправляющей стороной
				elseif lastStatus = "COMPLETED" then
					refresh = 1
          donemove = 1
				'ЭСЧФ создан, подписан обеими сторонами
				elseif lastStatus = "COMPLETED_SIGNED" then
					refresh = 1
          donemove = 1
				'На согласовании
				' Данный статус присваивается для дополнительных и исправленных ЭСЧФ в следующих случаях:
				' -   Когда на исходный (исправленный) счет-фактуру, который подписан обеими сторонами,
				' выставляется дополнительный ЭСЧФ с отрицательной суммой;
				' -   Когда на исходный (исправленный) счет-фактуру, который подписан обеими сторонами,
				' выставляется исправленный ЭСЧФ.
				elseif lastStatus = "ON_AGREEMENT" then
					refresh = 1
				'Аннулирован
				elseif lastStatus = "CANCELLED" then
						refresh = 0
            donemove = 1
				'Не найден
				elseif lastStatus = "NOT_FOUND" then
						refresh = 0
				'На согласовании на аннулирование
				elseif lastStatus = "ON_AGREEMENT_CANCEL" then
					refresh = 1
				'ЭСЧФ создан, не подписан
				elseif lastStatus = "IN_PROGRESS" then
					refresh = 1
				'ЭСЧФ создан, не подписан, содержит ошибки
				elseif lastStatus = "IN_PROGRESS_ERROR" then
					refresh = 1
				elseif lastStatus = "DENIED" then
					refresh = 0
                'Ошибка при выставлении ЭСЧФ на портал
				elseif lastStatus = "ERROR" then
					refresh = 0
				else
					'Неизвестный статус
					refresh = 1
				end if
				
				if refresh = 1 then
				'   RefreshInvStatus(invVatNumber)
				end if	

			  if donemove = 1 then
        coltomove = Filter(basecol, "invoice-" & invVatNumber)
        colexcept = Filter(Filter(coltomove, "-status-"), ".text.xml")
        for each exception in colexcept
          coltomove  = Filter(coltomove, exception, false)
        next
        MoveToDone coltomove, objFolder
        end if
		  '	end if	
	Next	
	
	if cnt = 0 then
	   WScript.Echo "Документы для обработки не обнаружены"
	end if
  end sub
  
  
  function FindLastStatusFor(invVatNumber, colFiles, objFolder)
	dim myRegExp
	dim status
	dim onDate
	dim dtStr
	dim StatusXml
	
	onDate = " "
	status = ""

	For Each objFile in colFiles
      
		
			'set StatusXml = EVatService.CreateEDoc
			'if StatusXml.LoadFromFile(CStr(objFolder.Path & "\" & objFile)) <> 0 then
				'WScript.Echo "Ошибка чтения файла " & fn & ": " & EVatService.LastError
			'else
				'dtStr = StatusXml.Document.GetXmlNodeValue("status_info/document_state/since") 
				'if dtStr > onDate then
					'onDate = dtStr
					'status = StatusXml.Document.GetXmlNodeValue("status_info/document_state/status") 
					status  = replace(Mid(objFile, 53, len(objFile)-56), ".text", "")
      					'WScript.Echo "статус: " & status
				'end if   
			'end if 
	Next	
	
	FindLastStatusFor = status
	
  end function
  
  
  'sub RefreshInvStatus(InvNumber)
      'WScript.Echo "Получение статуса счета-фактуры с номером " & InvNumber & ": "
  
	  'set EDocStatusInfo = EVatService.GetStatus(InvNumber)  
	  'if EDocStatusInfo is Nothing then
	'	  WScript.Echo "Ошибка при получении статуса счета-фактуры с номером " & InvNumber & ": " + EVatService.LastError
		  
	'	  exit sub
	'  else
	'	  dt = FormatDate(Date)

	'	  res = EDocStatusInfo.Verify
	'	  if res <> 0 then
	'		 WScript.Echo "Ошибка проверки полученного документа: " & EVatService.LastError & " (    0x" & Hex(res) & ")"
			 
        '     fn = oFSO.BuildPath(FolderName, "invoice-" & InvNumber & "-status-" & dt & "-" & EDocStatusInfo.Status & ".error")
        '  else
	'	     WScript.Echo "Статус обработки ЭСЧФ: " + EDocStatusInfo.Status
        '     WScript.Echo "Дополнительная информация: " + EDocStatusInfo.Message
        '     WScript.Echo "Дата установки статуса ЭСЧФ: " + EDocStatusInfo.Since
			  
	'	     fn = oFSO.BuildPath(FolderName, "invoice-" & InvNumber & "-status-" & dt & "-" & EDocStatusInfo.Status)
	'	  end if		  
		  
	'	  res = EDocStatusInfo.SaveToFile( fn & ".xml" )
	'	  if res <> 0 then
	'		 WScript.Echo "Ошибка сохранения полученного документа статуса: " & EVatService.LastError & " (Код 0x" & Hex(res) & ")"
	'		 WScript.quit
	'	  end if
          
        '  res = EDocStatusInfo.Document.SaveToFile( fn & ".text.xml" )
	'	  if res <> 0 then
	'	     WScript.Echo "Ошибка сохранения текста статуса: " & EVatService.LastError & " (Код 0x" & Hex(res) & ")"
	'	     WScript.quit
	'	  end if          
		
	'	  WScript.Echo "Файл информации о статусе " & fn & ".xml" & " сохранен"	  
	'  end if
  'end sub
    

 Function FormatDate(myDate)
    d = WhatEver(Day(myDate))
    m = WhatEver(Month(myDate))    
    y = Year(myDate)	
    FormatDate= y & "_" & m & "_" & d
End Function

Function WhatEver(num)
    If(Len(num)=1) Then
        WhatEver="0" & num
    Else
        WhatEver = num
    End If
End Function  

Function GetEnvVar(envVarName, defValue)
  dim v
  v = wshShell.ExpandEnvironmentStrings( "%" & envVarName & "%" )
  if (v = "") or (v = ("%" & envVarName & "%")) then
     v = defValue
  end if  
  GetEnvVar = v
End Function
 
Function MoveToDone(coltomove, objFolder)
dim objfile
  For Each objfile in coltomove
    Set filetomove = oFSO.GetFile(CStr(objFolder.Path & "\" & objFile))
    filetomove.Move(CStr(replace(objFolder.Path, "out", "done") & "\" & objFile))
  Next
End Function