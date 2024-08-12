// =============================================================================
// TharlGate: bnrSignupData.lsl
// bnrSignupData: Register riders for a race - Data Operations
// TharlGate, All rights reserved; Copyright 2016-2024; LauraTarnsman Resident
// Work in Progress:
// __ Fix "close" command and racer/manager signup issues
// Start Over setting step to MgtStart, and calling MenuAddName (not Startup)
// ============================== Upd 2024-08-12 ============================
// Configuration
string m_csVersion = "bnrSignupData (2024-08-12)";
integer m_bDebug = FALSE;
integer m_iNLeagues = 3;

float m_fTime;
string m_sBellSound = "5c6ece09-c5ff-6c67-2058-fc9ae7274e17";
string m_sThaisKey = "680601ff-b624-4eab-941b-5382f4e2f0d4";
string m_sKylieKey = "3f6b1612-6cc3-4548-85e4-3aef3969d2e9";
string m_sSandiKey = "4bf82070-2692-4e86-8936-674a1b103954";
string m_sMyPrefix = "d-";

// Sample Cards
integer m_iDataPage; // Menu page for requested data cards
string m_sDataCard;  // Data card name for saved races

// Manage Race--module because only one manager
string m_sManagerList; // List of managers
integer m_bIsManager;
integer m_iManageMode;
integer m_bRegistrationOpen;
string m_sTrackName;
string m_sNextRaceDayTime;
string m_sRaceDate;
string m_sRaceTime;
string m_sRaceDayTime;
string m_sRaceStatus;
integer m_iNEntries;
integer m_iOpenRegCode; // Unix date code for open registration time
string m_sManageStep;
string m_sKeyMgr;
string m_sMgrName;
string m_sPickRacer;

// Rider Database
string m_sRiderDataList;
integer m_iRacerPage; // Current page of manager Pick Racer dialog

// Current Rider Fields: Module variables must be used only in "locked code"
// where the thread never leaves the current module, because if another rider
// begins a data entry and the thread is messaging another module, the value
// may be changed during the message delay. This is accomplished by calling
// sLoadRiderData(keyDlg, sUserName) in the module prier to any access of
// these module fields.
string m_sKeyRider;
string m_sRiderLegacyName;
string m_sRiderDisplayName;
string m_sRiderLeague;
string m_sRiderTeam;
string m_sTharl1;
string m_sTharl2;
string m_sTharl3;
string m_sTharl4;
string m_sTharl5;
string m_sRiderStep;

// Comm
integer m_iDialogChannel;
integer m_iDialogHandle;
integer m_bNewRaceOpen;
integer m_iDialogCounter;
integer m_iManagerCounter; // Manager time out after 1 minute

//==============================================================================
// InitializeData: Perform State Entry initialization
//==============================================================================
InitializeData()
{
    // Set listener and time-out
    llSetTimerEvent(1);
    SendLnkCmd("m-m_iDialogChannel", "", m_iDialogChannel);

    // Set initial race data
    InitializeRace();
}
//==============================================================================
// InitializeRace: Clear race fields
//==============================================================================
InitializeRace()
{
    m_sTrackName = llGetSubString(llGetObjectDesc(), 1, -1);
    SendLnkCmd("m_sTrackName", m_sTrackName, 0);
    SendLnkCmd("m_iNLeagues", "", m_iNLeagues);
    m_sRiderDataList = "";
    SendLnkCmd("m_sRiderDataList", m_sRiderDataList, 0);
}
//==============================================================================
// CheckManager: See if user is in manager list
//==============================================================================
CheckManager(string sUserName)
{
    m_bIsManager = FALSE;
    if (llSubStringIndex(m_sManagerList, "|" + sUserName + "|") >= 0)
        m_bIsManager = TRUE;
}
//==============================================================================
// SendTrackInfo: Send track name and race time to RaceForm
// Target Module is "f" for RaceForm, "m" for SignupMenu, "h" for SignupHelper
//==============================================================================
SendTrackInfo(string sTargetModule)
{
    string sPrefix = sTargetModule + "-";
    SendLnkCmd(sPrefix + "m_sRiderDataList", m_sRiderDataList, 0);
    SendLnkCmd(sPrefix + "m_sTrackName", m_sTrackName, 0);
    SendLnkCmd(sPrefix + "m_sRaceDate", m_sRaceDate, 0);
    SendLnkCmd(sPrefix + "m_sRaceTime", m_sRaceTime, 0);
    SendLnkCmd(sPrefix + "m_sRaceDayTime", m_sRaceDayTime, 0);
    SendLnkCmd(sPrefix + "m_iNLeagues", "", m_iNLeagues);
    SendLnkCmd(sPrefix + "m_sRaceStatus", m_sRaceStatus, 0);
}
//==============================================================================
// PresentRiderData: Display notecard in chat
//==============================================================================
PresentRiderData(key keyDlg)
{
    string sMsg = "Your race information:\n" +
                  m_sRaceStatus + sGetFullName() + " - " + m_sTrackName +
                  " " + m_sRaceDate + "\n\n";
    sMsg += sAddRiderInfo(1, m_sTharl1);
    sMsg += sAddRiderInfo(2, m_sTharl2);
    sMsg += sAddRiderInfo(3, m_sTharl3);
    sMsg += sAddRiderInfo(4, m_sTharl4);
    sMsg += sAddRiderInfo(5, m_sTharl5);

    llRegionSayTo(keyDlg, 0, sMsg);
    SendLnkCmd("f-SendIM", sMsg, 0);
}
//==============================================================================
// sAddRiderInfo: Add a rider to the notecard info
//==============================================================================
string sAddRiderInfo(integer iDiv, string sRiderTharl)
{
    string sMsg;
    string sDiv = " Div " + (string)iDiv;
    string sLeague = m_sRiderLeague + sDiv;

    if (iDiv == 4)
    {
        sLeague = "Open";
    }
    else if (iDiv == 5)
    {
        sLeague = "Bloodbath Div 2";
    }

    if (sRiderTharl != "")
    {
        sMsg += sLeague + " - " +
                sGetFullName() + " on " + sRiderTharl;
        if (m_sRiderTeam != "")
            sMsg += " riding for " + m_sRiderTeam;
        sMsg += "\n";
    }

    return sMsg;
}
//==============================================================================
// sGetFullName: Get display and legacy name string
//==============================================================================
string sGetFullName()
{
    string sName;

    sName = m_sRiderDisplayName;
    if (m_sRiderDisplayName != m_sRiderLegacyName)
    {
        sName = sName + " (" + m_sRiderLegacyName + ")";
    }

    return sName;
}
//==============================================================================
// Return Display name for keyID
//==============================================================================
string sGetDisplayName(key keyID)
{
    string sDisplayName = llGetDisplayName(keyID);

    // Remove "Resident"
    sDisplayName = sRemoveResident(sDisplayName);

    return (sDisplayName);
}
//==============================================================================
// Return Display name for keyID
//==============================================================================
string sRemoveResident(string sName)
{
    // Remove "Resident"
    integer iLoc = llSubStringIndex(sName, " Resident");
    if (iLoc > 0)
        sName = llGetSubString(sName, 0, iLoc - 1);

    return sName;
}
//==============================================================================
// DisplayMenu: Call menu from SignupMenus module
//==============================================================================
DisplayMenu(key keyDlg, string sMenuName)
{
    SetDialogListener();
    string sCmd = "m-" + sMenuName;
    // DebugTrace("DisplayMenu " + sCmd);
    SendLnkCmd(sCmd, keyDlg, m_bIsManager);
}
//==============================================================================
// SetRiderListener: Open a listener and save the handle
// =============================================================================
SetDialogListener()
{
    if (!m_iDialogHandle)
    {
        m_iDialogHandle = llListen(m_iDialogChannel, "", "", "");
    }
    m_iDialogCounter = 300; // Set dialog countdown to 5 minutes
}
//==============================================================================
// CloseMenu: Close a dialog and its channel
//==============================================================================
CloseMenu()
{
    // Remove dialog listener
    llListenRemove(m_iDialogHandle);
    m_iDialogHandle = FALSE;
    m_iDialogCounter = 0;
    ClearMgr();
}
//==============================================================================
// MenuResponse: Respond to a dialog on the open channel
//==============================================================================
MenuResponse(key keyDlg, string sUserName, string sMsg)
{
    sMsg = llStringTrim(sMsg, STRING_TRIM);
    m_iDialogCounter = 300; // Reset dialog countdown to 5 minutes
    DebugTrace("MenuResponse User/Msg/Step(" + sUserName + "/" +
               sMsg + "/" + m_sManageStep + ")");

    if (sMsg == "Manage")
    {
        // Manage: Don't lock out current managers
        if (m_sKeyMgr != "" && m_sKeyMgr != keyDlg)
        {
            string sText = "Banner is currently being managed by " +
                           llGetDisplayName(m_sKeyMgr) + "\nPlease try later.";
            llDialog(keyDlg, sText, [], m_iDialogChannel);
            return;
        }
        m_sManageStep = "MgtStart";
        m_sKeyMgr = keyDlg;
        m_sMgrName = llGetDisplayName(keyDlg);
        DisplayMenu(keyDlg, "MenuManage");
        m_iManagerCounter = 60; // Reset manage timeout to 60 secs
        return;
    }
    else if (sMsg == "Show Data" && m_bIsManager)
    {
        // Show Data
        ShowData(keyDlg);
        m_sManageStep = " ";
        m_sRiderStep = " ";
        ClearMgr();
        return;
    }
    else if (sMsg == "Save Data")
    {
        // Save Data
        SaveData(keyDlg);
        m_sManageStep = " ";
        m_sRiderStep = " ";
        ClearMgr();
        return;
    }
    else if (keyDlg == m_sKeyMgr)
    {
        //  ============= Manager Menu ==============
        m_iManagerCounter = 60; // Reset manage timeout to 60 secs
        if (sMsg == "Clear Data")
        {
            // Select Clear Data
            m_sManageStep = "MgtClear";
            DisplayMenu(keyDlg, "MenuConfirmClear");
        }
        else if (sMsg == "Clear Data!")
        {
            // Confirm Clear Data
            DisplayMenu(keyDlg, "DialogSayClearing");

            // Reset other scripts
            llResetOtherScript("bnrSignupMenu");
            llResetOtherScript("bnrRaceForm");
            llSleep(1);

            // Reset this script
            llResetScript();
        }
        else if (sMsg == "New Race")
        {
            // Select New Race
            m_sManageStep = "NewClear";
            DisplayMenu(keyDlg, "MenuConfirmNew");
        }
        else if (sMsg == "New Race!")
        {
            // Confirm New Race
            InitializeRace();

            // AutoSet next race time and date
            m_sRaceDayTime = m_sNextRaceDayTime;
            SendLnkCmd("h-SetNextRaceDay", "", 0);
            SendLnkCmd("m-SetRaceDayTime", "", 0);
            m_bRegistrationOpen = TRUE;
            SendLnkCmd("m_bRegistrationOpen", "", m_bRegistrationOpen);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
            ClearMgr();
            return;
        }
        else if (sMsg == "Open Reg")
        {
            // Open Reg
            m_bRegistrationOpen = TRUE;
            SendLnkCmd("m_bRegistrationOpen", "", m_bRegistrationOpen);
            SendLnkCmd("m-SetRaceStatus", m_sRiderDataList, 0);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
        }
        else if (sMsg == "Close Reg")
        {
            // Close Reg
            m_bRegistrationOpen = FALSE;
            SendLnkCmd("m_bRegistrationOpen", "", m_bRegistrationOpen);
            SendLnkCmd("m-SetRaceStatus", m_sRiderDataList, 0);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
        }
        else if (sMsg == "Race Form")
        {
            // Race Form
            SendTrackInfo("f");
            SendLnkCmd("f-Race Form", (string)keyDlg, 0);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
        }
        else if (sMsg == "Edit Racer")
        {
            // Edit Racer
            m_sManageStep = "MgtPickRacer";
            m_iRacerPage = 0;
            m_sPickRacer = "";
            SendLnkCmd("m-m_iRacerPage", "", m_iRacerPage);
            SendLnkCmd("m-m_sRiderDataList", m_sRiderDataList, 0);
            DisplayMenu(keyDlg, "MenuPickRacer");
        }
        else if (m_sManageStep == "MgtPickRacer")
        {
            // Choose racer to edit
            if (sMsg == ">>")
            {
                m_iRacerPage++;
            }
            else if (sMsg == "<<")
            {
                m_iRacerPage--;
            }
            else
            {
                m_sManageStep = "MgtPickEdit";
                m_sPickRacer = sMsg;
                SendLnkCmd("m-m_sPickRacer", m_sPickRacer, 0);
                return;
            }
            SendLnkCmd("m-m_iRacerPage", "", m_iRacerPage);
            DisplayMenu(keyDlg, "MenuPickRacer");
        }
        else if (m_sManageStep == "MgtPickEdit")
        {
            // Choose edit action for racer
            // DebugTrace("Call EditRacer(" + m_sPickRacer + "," + sMsg + ")");
            string sPickEdit = sMsg;
            string sData = m_sPickRacer + "|" + sPickEdit;
            SendLnkCmd("h-m_sRiderDataList", m_sRiderDataList, 0);
            SendLnkCmd("h-EditRacer", sData, 0);
            DisplayMenu(keyDlg, "MenuManage");
        }
        else if (sMsg == "Load Data")
        {
            // Load Data
            SendLnkCmd("m-SetRaceStatus", m_sRiderDataList, 0);
            m_sManageStep = "MgtPickData";
            m_iDataPage = 0;
            SendLnkCmd("m-m_iDataPage", "", m_iDataPage);
            DisplayMenu(keyDlg, "MenuPickData");
        }
        else if (m_sManageStep == "MgtPickData")
        {
            // Select race data notecard from list
            if (sMsg == ">>")
            {
                m_iDataPage++;
            }
            else if (sMsg == "<<")
            {
                m_iDataPage--;
            }
            else if (sMsg == "Recover")
            {
                SendLnkCmd("h-RecoverData", keyDlg, 0);
                m_sManageStep = " ";
                m_sRiderStep = " ";
                ClearMgr();
                return;
            }
            else if (sMsg == "ShowRcovr")
            {
                SendLnkCmd("h-ShowRecovery", keyDlg, 0);
                ClearMgr();
                return;
            }
            else
            {
                m_sDataCard = sMsg;
                SendLnkCmd("m-Load Card", m_sDataCard, 0);
                return;
            }
            SendLnkCmd("m-Load Data", sMsg, 0);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
        }
        else if (sMsg == "Done")
        {
            // Done: End manager actions
            ClearMgr();
            llRegionSayTo(keyDlg, 0, m_sRaceStatus);
            if (keyDlg == m_sThaisKey || keyDlg == m_sKylieKey)
            {
                DisplayMemory(keyDlg);
                SendLnkCmd("DisplayMemory", (string)keyDlg, 0);
            }
            m_iManagerCounter = 0; // Reset manage timeout to 0
        }
        return;
    }

    //  ============= Racer Menu ==============
    if (sMsg == "Cancel" || sMsg == "OK")
        return;
    ClearMgr();
    // sLoadRiderData loads sRiderEntry and its field values
    DebugTrace("MenuResponse-B User/Msg/RiderStep(" + sUserName + "/" +
               sMsg + "/" + m_sRiderStep + ")");
    string sRiderEntry = sLoadRiderData(keyDlg, sUserName);
    // DebugTrace("sMsg/RiderStep=" + sMsg + "/" + m_sRiderStep);

    if (sMsg == "Close" || sMsg == "Done" || sMsg == "See My Data")
    {
        // Cancel, Close, Done, See Data
        m_sRiderStep = " ";
        if (m_sTharl1 + m_sTharl2 + m_sTharl3 + m_sTharl4 + m_sTharl5 == "")
        {
            Unregister(keyDlg);
            return;
        }
        else
        {
            // Done || See My Data
            PresentRiderData(keyDlg);
            m_sRiderStep = " ";
            sUpdateRiderEntry(keyDlg);
            DisplayMenu(keyDlg, "MenuComplete");
            return;
        }
    }
    else if (sMsg == "Change Data" || sMsg == "Start Over")
    {
        // Change Data
        ClearRiderFields(FALSE);
        m_sRiderStep = "Startup";
        sUpdateRiderEntry(keyDlg);
        SendLnkCmd("m-SetRaceStatus", m_sRiderDataList, 0);
        DisplayMenu(keyDlg, "MenuStartup");
    }
    else if (sMsg == "Un-Register" || sMsg == "Cancel Reg")
    {
        Unregister(keyDlg);
        return;
    }
    else if (m_sRiderStep == "Startup")
    {
        // DebugTrace("Startup: League=" + m_sRiderLeague +
        //           " Team=[" + m_sRiderTeam + "]");
        // Add Entry--Choose league
        // If user is new then add a new rider entry
        m_sRiderLeague = sMsg;
        m_sRiderStep = "Team";
        sUpdateRiderEntry(keyDlg);
        DisplayMenu(keyDlg, "MenuTeam");
    }
    else if (m_sRiderStep == "Team")
    {
        // DebugTrace("Team: Tharls=[" + m_sTharl1 + " / " + m_sTharl2 + " / " +
        //           m_sTharl3 + " / " + m_sTharl4 + " / " + m_sTharl5 + "]");

        // Add Team
        sMsg = sRemoveCRs(sMsg);
        m_sRiderTeam = sMsg;
        if (m_sRiderTeam == "")
        {
            m_sRiderTeam = "-";
        }
        m_sRiderStep = "AddDiv";
        sUpdateRiderEntry(keyDlg);
        DisplayMenu(keyDlg, "MenuAddDiv");
    }
    else if (m_sRiderStep == "AddDiv")
    {
        // DebugTrace("AddDiv: Tharls=[" + m_sTharl1 + " / " + m_sTharl2 + " / " +
        //           m_sTharl3 + " / " + m_sTharl4 + " / " + m_sTharl5 + "]");
        // Add Div
        if (sMsg == "Div 1")
        {
            m_sRiderStep = "AddName1";
        }
        else if (sMsg == "Div 2")
        {
            m_sRiderStep = "AddName2";
        }
        else if (sMsg == "Div 3")
        {
            m_sRiderStep = "AddName3";
        }
        else if (sMsg == "Open")
        {
            m_sRiderStep = "AddName4";
        }
        else if (sMsg == "Bloodbath-D2")
        {
            m_sRiderStep = "AddName5";
        }
        sUpdateRiderEntry(keyDlg);
        DisplayMenu(keyDlg, "MenuAddName");
    }
    else if (llSubStringIndex(m_sRiderStep, "AddName") >= 0)
    {
        // Add Tharl Name
        sMsg = sRemoveCRs(sMsg);
        if (sMsg == "")
        {
            DisplayMenu(keyDlg, "MenuAddName");
            return;
        }
        else if (m_sRiderStep == "AddName1")
        {
            m_sTharl1 = sMsg;
        }
        else if (m_sRiderStep == "AddName2")
        {
            m_sTharl2 = sMsg;
        }
        else if (m_sRiderStep == "AddName3")
        {
            m_sTharl3 = sMsg;
        }
        else if (m_sRiderStep == "AddName4")
        {
            m_sTharl4 = sMsg;
        }
        else if (m_sRiderStep == "AddName5")
        {
            m_sTharl5 = sMsg;
        }

        // Mark already selected buttons with "-"
        string sButtons;
        sButtons = sAddMarker(m_sTharl1, sButtons);
        sButtons = sAddMarker(m_sTharl2, sButtons);
        sButtons = sAddMarker(m_sTharl3, sButtons);
        sButtons = sAddMarker(m_sTharl4, sButtons);
        sButtons = sAddMarker(m_sTharl5, sButtons);
        string sCommand = "MenuAddDiv" + sButtons;

        // Repeat Add Div
        m_sRiderStep = "AddDiv";
        sUpdateRiderEntry(keyDlg);
        SendLnkCmd("m-SetRaceStatus", m_sRiderDataList, 0);
        DisplayMenu(keyDlg, "MenuAddDiv" + sButtons);
    }
}
//==============================================================================
string sAddMarker(string sRider, string sButtons)
{
    if (sRider != "")
    {
        sButtons += "-";
    }
    else
    {
        sButtons += " ";
    }
    return sButtons;
}
//==============================================================================
// RemoveCRs: Truncate input before the first CR to remove multiple lines
//==============================================================================
string sRemoveCRs(string sMsg)
{
    integer iLoc = llSubStringIndex(sMsg, "\n");
    if (iLoc >= 0)
    {
        sMsg = llGetSubString(sMsg, 0, iLoc - 1);
    }
    return sMsg;
}
//==============================================================================
// Clear Mgr: Clear the manager permissions once in a rider dialog or done
//==============================================================================
ClearMgr()
{
    m_sKeyMgr = "";
    m_bIsManager = FALSE;
    m_iManagerCounter = 0;
}
//==============================================================================
// Unregister: Clear rider fields, remove record, and inform racer
//==============================================================================
Unregister(key keyDlg)
{
    // Un-Register
    m_sRiderDataList = sRemoveRiderEntry(keyDlg);
    ClearRiderFields(TRUE);
    SendLnkCmd("m-SetRaceStatus", m_sRiderDataList, 0);
    m_sRiderStep = " ";
    DisplayMenu(keyDlg, "MenuDeleted");
}
//==============================================================================
// EditRacer: Scratch or reset racer league.
//==============================================================================
EditRacer(string sPickRacer, string sPickEdit)
{
    // Send to helper script to edit the m_sRiderDataList
    SendLnkCmd("h-m_sRiderDataList", m_sRiderDataList, 0);
    string sData = sPickRacer + "|" + sPickEdit;
    SendLnkCmd("h-EditRacer", sData, 0);
    // SignupHelper will return an updated copy of m_sRiderDataList
}
//==============================================================================
// Show Data: Send call to RaceForm to show all current race entries
//==============================================================================
ShowData(key keyDlg)
{
    SendTrackInfo("f");
    SendLnkCmd("f-Show Data", (string)keyDlg, 0);
}
//==============================================================================
// Save Data: Send call to RaceForm to show all current race entries
//==============================================================================
SaveData(key keyDlg)
{
    SendTrackInfo("h");
    SendLnkCmd("h-m_sRaceDate", m_sRaceDate, 0);
    SendLnkCmd("h-m_sRaceTime", m_sRaceTime, 0);
    SendLnkCmd("h-m_sRiderDataList", m_sRiderDataList, 0);
    SendLnkCmd("h-SaveData", (string)keyDlg, 0);
}
//==============================================================================
// Data Operations
//==============================================================================
// sLoadRiderData: Load data from current avatar into single fields
//==============================================================================
string sLoadRiderData(string sKeyDlg, string sRiderLegacyName)
{
    // Get the entry for this rider from the database
    string sKeyRider = llGetSubString(sKeyDlg, 0, 7);
    string sRiderEntry = sGetRiderEntry(sKeyRider);

    // If not found, add a new startup entry for this rider and get entry
    if (sRiderEntry == "" && sRiderLegacyName != "")
    {
        sRiderEntry = sAddRiderEntry(sKeyDlg, sRiderLegacyName);
    }

    // Load the module fields
    LoadRiderFields(sRiderEntry);
    return sRiderEntry;
}
//==============================================================================
// sGetRiderEntry: Locate and return the data record for the selected rider
// If not found, return empty string
//==============================================================================
string sGetRiderEntry(string sKeyRider)
{
    // A data entry has 11 fields: (step is the registration stage for each racer)
    // "sKeyRider,sRiderStep,sSLName,sDispName,sLeague,sTeam,
    //  Tharl1,Tharl2,Tharl3,Tharl4,Tharl5|"

    // Find sKeyRider and the rest of the entry
    sKeyRider = llGetSubString(sKeyRider, 0, 7);
    integer iBeg = llSubStringIndex(m_sRiderDataList, sKeyRider);
    string sRiderEntry;

    if (iBeg >= 0)
    {
        // Extract the entry
        string sSubDataList = llGetSubString(m_sRiderDataList, iBeg, -1);
        integer iEnd = iBeg + llSubStringIndex(sSubDataList, "|");
        sRiderEntry = llGetSubString(m_sRiderDataList, iBeg, iEnd);
    }
    return sRiderEntry;
}
//==============================================================================
// sAddRiderEntry: Add a new data entry for a rider not in the database
// =============================================================================
string sAddRiderEntry(string sKeyDlg, string sRiderLegacyName)
{
    // Calculate unique dialog channel and display name
    sRiderLegacyName = sRemoveResident(sRiderLegacyName);
    m_sRiderDisplayName = sGetDisplayName(sKeyDlg);
    m_sRiderStep = "Startup";

    // Create initial data record containing key, channel, leg and disp names
    string sKeyRider = llGetSubString(sKeyDlg, 0, 7);
    string sRiderEntry = sKeyRider;
    sRiderEntry += "," + m_sRiderStep;
    sRiderEntry += "," + sRiderLegacyName;
    sRiderEntry += "," + m_sRiderDisplayName;
    sRiderEntry += ", , , , , , , |";

    // Append data record to the database and return it
    m_sRiderDataList += sRiderEntry;

    return sRiderEntry;
}
//==============================================================================
// LoadRiderFields: Load data from current avatar into single fields
//==============================================================================
LoadRiderFields(string sRiderEntry)
{
    // Parse the entry and load the module fields
    list lstRiderData = llParseString2List(sRiderEntry, [","], ["|"]);

    // Get fields from data
    m_sKeyRider = llList2String(lstRiderData, 0);
    m_sRiderStep = llList2String(lstRiderData, 1);
    m_sRiderLegacyName = llList2String(lstRiderData, 2);
    m_sRiderDisplayName = llList2String(lstRiderData, 3);
    m_sRiderLeague = sGetField(lstRiderData, 4);
    m_sRiderTeam = sGetField(lstRiderData, 5);
    m_sTharl1 = sGetField(lstRiderData, 6);
    m_sTharl2 = sGetField(lstRiderData, 7);
    m_sTharl3 = sGetField(lstRiderData, 8);
    m_sTharl4 = sGetField(lstRiderData, 9);
    m_sTharl5 = sGetField(lstRiderData, 10);
    if (m_sRiderLegacyName == "")
    {
        llPlaySound(m_sBellSound, 0.5);
    }
}
//==============================================================================
// sGetField: Get a selected field from a list, trimmed
//==============================================================================
string sGetField(list lstRiderData, integer iFieldNo)
{
    // Get the entry for this rider from the database
    string sField = llList2String(lstRiderData, iFieldNo);
    sField = llStringTrim(sField, STRING_TRIM);
    return sField;
}
//==============================================================================
// sCreateRiderEntry: Create database record for current fields
// =============================================================================
string sUpdateRiderEntry(string sKeyRider)
{
    // Remove old rider entry from m_sRiderDataList
    m_sRiderDataList = sRemoveRiderEntry(sKeyRider);

    // Create database record for current fields
    // DebugTrace("sUpdateRiderEntry");
    sKeyRider = llGetSubString(sKeyRider, 0, 7);
    string sRiderEntry = sKeyRider;
    sRiderEntry = sAddField(sRiderEntry, m_sRiderStep);
    sRiderEntry = sAddField(sRiderEntry, m_sRiderLegacyName);
    sRiderEntry = sAddField(sRiderEntry, m_sRiderDisplayName);
    sRiderEntry = sAddField(sRiderEntry, m_sRiderLeague);
    sRiderEntry = sAddField(sRiderEntry, m_sRiderTeam);
    sRiderEntry = sAddField(sRiderEntry, m_sTharl1);
    sRiderEntry = sAddField(sRiderEntry, m_sTharl2);
    sRiderEntry = sAddField(sRiderEntry, m_sTharl3);
    sRiderEntry = sAddField(sRiderEntry, m_sTharl4);
    sRiderEntry = sAddField(sRiderEntry, m_sTharl5);
    sRiderEntry += "|";

    // Add changed rider entry to end of m_sRiderDataList
    m_sRiderDataList += sRiderEntry;
    // DebugTrace("sUpdateRiderEntry to " + sRiderEntry);

    // Send updated m_sRiderDataList to SignupMenu
    SendLnkCmd("m-m_sRiderDataList", m_sRiderDataList, 0);

    return sRiderEntry;
}
//==============================================================================
// sAddField: Append a new field to a data record, setting empties to a space
// =============================================================================
string sAddField(string sRecord, string sField)
{
    if (sField == "")
        sField = " ";
    sRecord += "," + sField;
    // DebugTrace("sAddField: " + sField + ": " + sRecord);
    return sRecord;
}
//==============================================================================
// ClearRiderFields: Erase current rider data
//==============================================================================
ClearRiderFields(integer bAll)
{
    // Clear data fields
    if (bAll)
    {
        m_sKeyRider = "";
        m_sRiderStep = "";
        m_sRiderLegacyName = "";
        m_sRiderDisplayName = "";
    }
    m_sRiderLeague = "";
    m_sRiderTeam = "";
    m_sTharl1 = "";
    m_sTharl2 = "";
    m_sTharl3 = "";
    m_sTharl4 = "";
    m_sTharl5 = "";
}
//==============================================================================
// bIsRegistered: Determine if racer has registered for any races yet
//==============================================================================
integer bIsRegistered(key keyRider)
{
    // DebugTrace("bIsRegistered: key/League/Tharl1 = " + m_sKeyRider +
    // "/" + m_sRiderLeague + "/" + m_sTharl1);
    // Not registered if no key or league
    if (m_sRiderLeague == "")
        return 0;

    // Not registered if no races
    if (m_sTharl1 == "" && m_sTharl2 == "" && m_sTharl3 == "" &&
        m_sTharl4 == "" && m_sTharl5 == "")
        return 0;

    return 1;
}
//==============================================================================
// RemoveRiderEntry: Remove existing rider record from the database
// =============================================================================
string sRemoveRiderEntry(string sKeyRider)
{
    string sSubDataList;
    string sRiderDataList;

    // DebugTrace("sRemoveRiderEntry " + sKeyRider);
    // Find sKeyTharl and remove racer data
    sKeyRider = llGetSubString(sKeyRider, 0, 7);
    integer iBeg = llSubStringIndex(m_sRiderDataList, sKeyRider);

    if (iBeg >= 0)
    {
        sSubDataList = llGetSubString(m_sRiderDataList, iBeg, iBeg + 170);
        integer iEnd = iBeg + llSubStringIndex(sSubDataList, "|");
        // DebugTrace("iBeg/iEnd=" + (string)iBeg + " / " + (string)iEnd);
        sRiderDataList = llDeleteSubString(m_sRiderDataList, iBeg, iEnd);
        // DebugTrace("m_sRiderDataList=[" + sRiderDataList + "]");
    }

    return sRiderDataList;
}
//==============================================================================
// LnkMsgResponse: Process and act on received link messages
//==============================================================================
LnkMsgResponse(string sCmd, key keyData, integer iNum)
{
    // Set debug; placed before debug can echo
    if (sCmd == "m_bDebug")
    {
        return;
    }

    string sData = (string)keyData;
    // DebugTrace("LnkRsp: " + sCmd + "," + sData + "," + (string)iNum);
    DebugTrace("LnkRsp: " + sCmd);

    if (sCmd == "m_sTrackName")
    {
        m_sTrackName = sData;
    }
    else if (sCmd == "m_sRaceDate")
    {
        m_sRaceDate = sData;
    }
    else if (sCmd == "m_sRaceTime")
    {
        m_sRaceTime = sData;
    }
    else if (sCmd == "m_sRaceDayTime")
    {
        m_sRaceDayTime = sData;
    }
    else if (sCmd == "m_sNextRaceDayTime")
    {
        m_sNextRaceDayTime = sData;
    }
    else if (sCmd == "m_sRaceStatus")
    {
        m_sRaceStatus = sData;
        m_iNEntries = iNum;
    }
    else if (sCmd == "m_iNLeagues")
    {
        m_iNLeagues = iNum;
    }
    else if (sCmd == "m_sRiderDataList")
    {
        m_sRiderDataList = sData;
        m_iNEntries = iNum;
    }
    else if (sCmd == "m_sManagerList")
    {
        m_sManagerList = sData;
    }
    else if (sCmd == "EndOfData")
    {
        m_sManageStep = "MgtStart";
        m_sKeyMgr = keyData;
        m_sMgrName = llGetDisplayName(m_sKeyMgr);
        DisplayMenu(keyData, "MenuManage");
    }
    else if (sCmd == "ShowData")
    {
        ShowData(m_sKeyMgr);
    }
}
//==============================================================================
// SendLnkCmd: Send a link message command
//==============================================================================
SendLnkCmd(string sCmd, string sData, integer iValue)
{
    // Truncate msg for DebugTrace
    string sMsg = llGetSubString(sData, 0, 400);
    DebugTrace("SndLnk " + sCmd + "," + sMsg + "," + (string)iValue);
    llMessageLinked(LINK_THIS, iValue, sCmd, sData);
}
// =========================================================================
// sSelectMsg: select only messages with no prefex or m_sMyPrefix (d-)
// =========================================================================
string sSelectMsg(string sMsg)
{
    // DebugTrace("sSelMsg: " + sMsg + "," + sMyPrefix);
    // Check the first 2 characters
    string sMsgPrefix = llGetSubString(sMsg, 0, 1);

    // Accept direct messages with my prefix
    if (sMsgPrefix == m_sMyPrefix)
    {
        string sMsg0 = sMsg;
        // Strip prefix
        sMsg = llGetSubString(sMsg, 2, -1);
    }
    // Ignore direct messages to others
    else if (llGetSubString(sMsg, 1, 1) == "-")
    {
        return "";
    }
    // Pass through all messages with my prefix or with no prefix
    return sMsg;
}
//==============================================================================
// DebugTrace(): llOwnerSay if in debug mode
// =============================================================================
DebugTrace(string sMsg)
{
    if (m_bDebug)
        llOwnerSay("[SignupData " + (string)llGetFreeMemory() + "] " + sMsg);
}
//==============================================================================
// DisplayMemory: Show version and free memory
//==============================================================================
DisplayMemory(key keyDlg)
{
    string sText = m_csVersion + " Free Memory: " + (string)llGetFreeMemory();
    if (keyDlg != "")
        llRegionSayTo(keyDlg, 0, sText);
    else
        llSay(0, sText);
}
// =============================================================================
// Event List
// =============================================================================
default
{
    // =========================================================================
    state_entry()
    {
        m_iDialogChannel = (integer)llFrand(DEBUG_CHANNEL) * -1;
        InitializeData();
        DisplayMemory("");
        llSetTimerEvent(1);
    }
    // =========================================================================
    on_rez(integer iNum)
    {
        llResetScript();
    }
    // =========================================================================
    touch_start(integer iNTouch)
    {
        m_fTime = llGetTime();
    }
    // =========================================================================
    touch_end(integer iNTouch)
    {
        key keyDlg = llDetectedKey(0);
        string sRiderLegacyName = llDetectedName(0);
        // DebugTrace("Tch: " + sRiderLegacyName);

        // Toggle debug if long click from Thais
        if (llGetTime() - m_fTime > 2 && keyDlg == m_sThaisKey)
        {
            m_bDebug = 1 - m_bDebug;
            SendLnkCmd("m_bDebug", "", m_bDebug);
            llWhisper(0, "m_bDebug = " + (string)m_bDebug);
            return;
        }

        // Set track tag and manager list
        m_sTrackName = llGetSubString(llGetObjectDesc(), 1, -1);
        SendLnkCmd("m_sTrackName", m_sTrackName, 0);

        // Get Status information
        SendLnkCmd("h-SetNextRaceDay", "", 0);
        SendLnkCmd("m-SetRaceStatus", m_sRiderDataList, 0);

        // Refresh m_iDialogChannel
        SendLnkCmd("m-m_iDialogChannel", "", m_iDialogChannel);

        // See if user is a manager
        CheckManager(sRiderLegacyName);

        // Load rider fields ======== Update module rider fields in module
        sLoadRiderData(keyDlg, sRiderLegacyName); // Get/add entry; load fields

        // Determine if registered for any races
        integer bRegistered = bIsRegistered(keyDlg);
        SendLnkCmd("m-m_sRiderStep", m_sRiderStep, 0);

        // Display the startup menu
        if (bRegistered)
        {
            // DebugTrace("tch-registered m_sRiderStep=" + m_sRiderStep);
            DisplayMenu(keyDlg, "MenuStartupReg"); // Already registered
        }
        else
        {
            // DebugTrace("tch-not-registered m_sRiderStep=" + m_sRiderStep);
            if (m_sRiderStep == "Team")
            {
                DisplayMenu(keyDlg, "MenuTeam");
            }
            else if (m_sRiderStep == "AddDiv")
            {
                DisplayMenu(keyDlg, "MenuAddDiv");
            }
            else if (llSubStringIndex(m_sRiderStep, "AddName") >= 0)
            {
                DisplayMenu(keyDlg, "MenuAddName");
            }
            else
            {
                m_sRiderStep = "Startup";
                DisplayMenu(keyDlg, "MenuStartup");
            }
        }
        return;
    }
    // ==========================================================================
    listen(integer iChannel, string sUserName, key keyID, string sMsg)
    {
        // DebugTrace("SD Listen: iChannel=" + (string)iChannel);
        // DebugTrace("SD Listen: sMsg=" + sMsg);
        //  Monitor dialog channel
        if (iChannel == m_iDialogChannel)
        {
            CheckManager(sUserName);
            MenuResponse(keyID, sUserName, sMsg);
        }
    }
    // ==========================================================================
    link_message(integer iSender, integer iNum, string sCmd, key keyData)
    {
        // Deselect messages with prefix to other modules
        sCmd = sSelectMsg(sCmd);

        if (sCmd == "")
            return;

        // Process all messages to me and to all
        LnkMsgResponse(sCmd, keyData, iNum);
    }
    // ==========================================================================
    timer()
    {
        if (m_iManagerCounter > 0)
        {
            if (--m_iManagerCounter == 0)
            {
                SendLnkCmd("m-MenuManagerTimeout", m_sKeyMgr, 0);
                ClearMgr();
            }
        }
        if (m_iDialogCounter > 0)
        {
            if (--m_iDialogCounter == 0)
            {
                CloseMenu();
            }
        }
    }
    // =========================================================================
}
// =============================================================================
 