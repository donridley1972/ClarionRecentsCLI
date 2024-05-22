  MEMBER('ClarionRecentsCLI.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('ClarionRecentsCLI_BC0.CLW')
ClarionRecentsCLI_BC0:DctInit             PROCEDURE()
ClarionRecentsCLI_BC0:DctKill             PROCEDURE()
ClarionRecentsCLI_BC0:FilesInit           PROCEDURE()
    END
  END

DctInit PROCEDURE()
  CODE
  ClarionRecentsCLI_BC0:DctInit
  ClarionRecentsCLI_BC0:FilesInit


DctKill PROCEDURE()
  CODE
  ClarionRecentsCLI_BC0:DctKill

