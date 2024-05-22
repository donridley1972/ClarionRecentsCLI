

   MEMBER('ClarionRecentsCLI.clw')                         ! This is a MEMBER module


   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('CLARIONRECENTSCLI001.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! </summary>
Main PROCEDURE 

x                   Long
RecentsPath          STRING(255)                           ! 
NewSolutionPath      STRING(255)                           ! 
ClarionVersion       STRING(10)                            ! 
RecentsQ             QUEUE,PRE(Rcnt)                       ! 
SlnPath              STRING(255)                           ! 
                     END                                   ! 
properties           GROUP,PRE(),NAME('Properties')        ! 
project_             GROUP,PRE(),NAME('Project')           ! 
value                STRING(5000),NAME('value | attribute') ! 
                     END                                   ! 
dictionary_          GROUP,PRE(),NAME('Dictionary')        ! 
value                STRING(5000),NAME('value | attribute') ! 
                     END                                   ! 
diagram              GROUP,PRE(),NAME('Diagram')           ! 
value                STRING(255),NAME('value | attribute') ! 
                     END                                   ! 
table_               GROUP,PRE(),NAME('Table')             ! 
value                STRING(5000),NAME('value | attribute') ! 
                     END                                   ! 
file_                GROUP,PRE(),NAME('File')              ! 
value                STRING(5000),NAME('value | attribute') ! 
                     END                                   ! 
                     END                                   ! 
st                  StringTheory
CmdSt               StringTheory
OutSt               StringTheory
xml                 xFilesTree
Window               WINDOW('Clarion Recents CI'),AT(,,457,301),FONT('Segoe UI',9),ICON(ICON:Clarion),GRAY,IMM
                       BUTTON('Close'),AT(413,276),USE(?Close)
                       LIST,AT(2,63,452,209),USE(?LIST1),VSCROLL,FORMAT('1020L(2)M~Recent Solutions~@s255@'),FROM(RecentsQ)
                       PROMPT('Clarion Version:'),AT(2,3,47,10),USE(?ClarionVersion:Prompt),TRN
                       ENTRY(@s10),AT(62,2,60,10),USE(ClarionVersion)
                     END

    omit('***',WE::CantCloseNowSetHereDone=1)  !Getting Nested omit compile error, then uncheck the "Check for duplicate CantCloseNowSetHere variable declaration" in the WinEvent local template
WE::CantCloseNowSetHereDone equate(1)
WE::CantCloseNowSetHere     long
    !***
ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
TakeWindowEvent        PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass

  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('Main')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Close
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)                 ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)                 ! Add the close control to the window manger
  END
    CmdSt.SetValue(COMMAND())  
  
    CmdSt.RemoveChars('"')
    ClarionVersion = CmdSt.Between('CV=','<32>')
    NewSolutionPath = CmdSt.Between('NS=','')
    !CmdSt.Trace('ClarionVersion[' & Clip(ClarionVersion) & ']')
    !CmdSt.Trace('NewSolutionPath[' & Clip(NewSolutionPath) & ']')
  SELF.Open(Window)                                        ! Open window
  
    If COMMAND()
        0{PROP:Hide} = TRUE
        If Not ClarionVersion
            POST(EVENT:CloseWindow)
        END
        If Not NewSolutionPath
            POST(EVENT:CloseWindow)
        End
    End
  Do DefineListboxStyle
  Alert(AltKeyPressed)  ! WinEvent : These keys cause a program to crash on Windows 7 and Windows 10.
  Alert(F10Key)         !
  Alert(CtrlF10)        !
  Alert(ShiftF10)       !
  Alert(CtrlShiftF10)   !
  Alert(AltSpace)       !
  WinAlertMouseZoom()
  WinAlert(WE::WM_QueryEndSession,,Return1+PostUser)
  INIMgr.Fetch('Main',Window)                              ! Restore window settings from non-volatile store
  SELF.SetAlerts()
    If COMMAND()
        RecentsQ.SlnPath = NewSolutionPath
        Add(RecentsQ)
    End
  
  
    !ClarionVersion = '11.0'
    RecentsPath = ds_GetFolderPath(WE::CSIDL_APPDATA) & '\SoftVelocity\Clarion\' & Clip(ClarionVersion) & '\RecentOpen.xml'
  
    st.LoadFile(Clip(RecentsPath))
    xml.start()
    xml.SetTagCase(xf:CaseAsIs)
    xml.Load(properties,st,'Properties') ! Load From a StringTheory object  
    !st.Trace(RecentsPath)
  
    
    st.SetValue(properties.project_.value,True)
    st.Split(',')
    
    Loop x = 1 to st.Records()
        RecentsQ.SlnPath = st.GetLine(x)
        
        Add(RecentsQ)
    End
  
    Clear(properties.project_.value,-1)
    Loop x = 1 to Records(RecentsQ)
        Get(RecentsQ,x)
        OutSt.AppendA(RecentsQ.SlnPath,True,',')
    End
  
    properties.project_.value = OutSt.GetValue()
  
    xml.start()
    xml.SetTagCase(xf:CaseAsIs)
    xml.SetDontSaveBlanks(true)
    xml.SetDontSaveBlankGroups(true)
    xml.Save(properties,st,'Properties') ! Save to a StringTheory object
  
    If COMMAND()
        st.SaveFile(Clip(RecentsPath))
        POST(EVENT:CloseWindow)
    End
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  If self.opened Then WinAlert().
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.Opened
    INIMgr.Update('Main',Window)                           ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.TakeEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeEvent()
  If event() = event:VisibleOnDesktop !or event() = event:moved
    ds_VisibleOnDesktop()
  end
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeWindowEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all window specific events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE EVENT()
    OF EVENT:CloseDown
      if WE::CantCloseNow
        WE::MustClose = 1
        cycle
      else
        self.CancelAction = cancel:cancel
        self.response = requestcancelled
      end
    END
  ReturnValue = PARENT.TakeWindowEvent()
    CASE EVENT()
    OF EVENT:OpenWindow
        post(event:visibleondesktop)
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue

